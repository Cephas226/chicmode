package com.ecoleti.messaging.serviceImpl;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.stereotype.Service;

import com.ecoleti.common.Utility;
import com.ecoleti.common.dao.AppFileDao;
import com.ecoleti.common.dto.SearchDTO;
import com.ecoleti.common.enums.FileType;
import com.ecoleti.common.model.AppFile;
import com.ecoleti.messaging.dao.EventDao;
import com.ecoleti.messaging.dao.EventUserDao;
import com.ecoleti.messaging.enums.EventType;
import com.ecoleti.messaging.model.Event;
import com.ecoleti.messaging.model.EventUser;
import com.ecoleti.messaging.model.Notification;
import com.ecoleti.messaging.model.NotificationType;
import com.ecoleti.messaging.service.IEventService;
import com.ecoleti.messaging.service.INotificationService;
import com.ecoleti.pedagogy.dao.StudentDao;
import com.ecoleti.pedagogy.enums.PresenceType;
import com.ecoleti.pedagogy.model.Parent;
import com.ecoleti.pedagogy.model.Student;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@Service
public class EventServiceImpl implements IEventService {
	
	@Autowired
	private EventDao eventDao;
	
	@Autowired
	private EventUserDao eventUserDao;
	
	@Autowired
	private StudentDao studentDao;
	
	private String EVENT_PATH = "";
	
	@Autowired
	private AppFileDao fileDao;
	
	@Value("${school}")
	private String school;
	
	@Autowired
	private INotificationService notificationService;
	
	@PostConstruct
	private void postConstruct() {
		String home = System.getProperty("user.home");
		EVENT_PATH = home + File.separator + "ecoleti"+ File.separator + "documents" + File.separator + school + File.separator + "events" + File.separator;
	}

	@Override
	public Event add(Event event, String token) {
		Long id = event.getId();
		Event saveEvent = eventDao.save(event);
		if(CollectionUtils.isNotEmpty(event.getFilesDTO())) {
			event.getFilesDTO().forEach(file -> {
				Date now = new Date();
				Long time = now.getTime();
				String fileExtension = file.getName().split("\\.")[1];
				String fileName = time.toString().concat(".").concat(fileExtension);
				String path = EVENT_PATH + saveEvent.getId() + File.separator + fileName;
				file.write(path);
				String fileDownloadUri = ServletUriComponentsBuilder
						.fromCurrentContextPath()
						.path("/event/file/")
						.path(saveEvent.getId().toString()+'/')
						.path(fileName)
						.toUriString();
				System.out.println(fileDownloadUri);
				AppFile appFile = new AppFile(FileType.EVENT);
				appFile.setOriginalName(file.getName());
				appFile.setName(fileName);
				appFile.setUri(fileDownloadUri);
				appFile.setElementId(saveEvent.getId());
				fileDao.save(appFile);
			});
		}
		if(id == null) {
			addNotification(saveEvent, token); 
		}
		return saveEvent;
	}

	private void addNotification(Event event, String token) {
			Utility.executeInSeparateThread(() -> {  
	            	List<Student> students = studentDao.getByClassIds(event.getSchoolYear(), event.getClassIds());
	        		if(CollectionUtils.isNotEmpty(students)) {
	        			students.forEach(s -> {
	        				if(CollectionUtils.isNotEmpty(s.getParents())) {		
	        					s.getParents().forEach(p -> {
	        						EventUser eventUser = new EventUser();
	        	        			eventUser.setEventId(event.getId());
	        	        			eventUser.setStart(event.getStart());
	        	        			eventUser.setEnd(event.getEnd());
	        	        			eventUser.setSchoolYear(event.getSchoolYear());
	        	        			eventUser.setParentId(p.getId());
	        	        			eventUser.setParentName(p.getFirstName() + " " + p.getLastName());
	        	        			eventUserDao.save(eventUser);				
	        					});
	        					Notification notification = new Notification();
	        					notification.setUsers(s.getParents().stream().map(Parent::getPhone1).collect(Collectors.toList()));	
            					notification.setContent(event.getTitle());
            					switch (event.getType()) {
        						case INFO:
        							notification.setTitle("Information");
        							break;
        						case AD:
        							notification.setTitle("Annonce");
        							break;
        						case ALERT:
        							notification.setTitle("Alerte");
        							break;
        						default:
        							break;
        						}	
	        					Map<String, String> data = new HashMap<>();
            					data.put("type", NotificationType.EVENT.name());
            					data.put("eventId", String.valueOf(event.getId()));
            					data.put("studentId", String.valueOf(s.getId()));
	        					notification.setData(data);
	        					notificationService.send(notification, token);
	        				}
	        			});
	        		}    
	        });  	
	}

	@Override
	public Event findById(Long id) {
		return null;
	}

	@Override
	public Page<Event> findAll(SearchDTO searchDTO) {
		EventType type = null;
		if(StringUtils.isNotBlank(searchDTO.getSecondaryKeyword())) {
			try {
				type = EventType.valueOf(searchDTO.getSecondaryKeyword().toUpperCase());
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		 Page<Event> page = eventDao.getAllFiltered(searchDTO.getSchoolYearOne(),
									   searchDTO.getKeyword(), 
									   type, 
									   PageRequest.of(searchDTO.getPage(), searchDTO.getSize(), Sort.by(Direction.DESC, "id")));
		 if(!page.isEmpty()) {
			 page.getContent().forEach(event -> {
				 List<AppFile> files = fileDao.findByElementIdAndType(event.getId(), FileType.EVENT);
					if(CollectionUtils.isNotEmpty(files)) {
						event.setFiles(files);
					}
			 });
		 }
		 
		 return page;
		 
	}

	@Override
	public void delete(Long id) {
		eventDao.deleteById(id);
	}

	@Override
	public Event update(Event event) {
		return eventDao.saveAndFlush(event);
	}

	@Override
	public List<Event> getByClassIds(List<Long> classIds, Integer schoolYearOne) {
		List<Event> events = eventDao.findDistinctByClassIdsInAndSchoolYearAndStartBefore(classIds, schoolYearOne, new Date(), Sort.by(Sort.Direction.DESC, "id"));
		events.forEach(event -> {
			List<AppFile> files = fileDao.findByElementIdAndType(event.getId(), FileType.EVENT);
			if(CollectionUtils.isNotEmpty(files)) {
				event.setFiles(files);
			}
		});
		return events;
	}

	@Override
	public byte[] getFile(Long eventId, String fileName) throws IOException {
		 List<AppFile> files = fileDao.findByNameAndElementIdAndType(fileName, eventId, FileType.EVENT);
		 if(CollectionUtils.isEmpty(files)) {
			 return null;
		 }
		 String path = EVENT_PATH + eventId + File.separator + files.get(0).getName();
		 return FileUtils.readFileToByteArray(new File(path));
	}
	
	@Override
	public Page<EventUser> findEventUsersByUserId(Long eventId, int page, int size) {
		return eventUserDao.findByEventIdAndSeen(eventId, true, PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "seenDate")));
	}
	
	@Override
	public void readByUser(Long parentId, int schoolYear) {
		List<EventUser> events = eventUserDao.findByParentIdAndSchoolYearAndStartBeforeAndEndAfterAndSeen(parentId, schoolYear, new Date(), new Date(), false);
		if(CollectionUtils.isEmpty(events)) {
			return;
		}
		events.forEach(e -> {
			e.setSeen(true);
			e.setSeenDate(new Date());
			eventUserDao.saveAndFlush(e);
			Optional<Event> event = eventDao.findById(e.getEventId());
			if(event.isPresent()) {
				event.get().setTotalSeen(event.get().getTotalSeen() + 1);
				eventDao.save(event.get());
			}
		});	
	}

	@Override
	public void deleteFile(Long eventId, String fileName){
		 List<AppFile> files =  fileDao.findByNameAndElementIdAndType(fileName, eventId, FileType.EVENT);
		 if(CollectionUtils.isEmpty(files)) {
			 return;
		 }
		 files.forEach(file -> fileDao.deleteById(file.getId()));
		 String path = EVENT_PATH + eventId + File.separator + files.get(0).getName();
		 try {
			FileUtils.forceDelete(new File(path));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@Override
	public int totalUnreadByUser(Long parentId, int schoolYear) {
		List<EventUser> events = eventUserDao.findByParentIdAndSchoolYearAndStartBeforeAndEndAfterAndSeen(parentId, schoolYear, new Date(), new Date(), false);
		return events.size();
	}
	
}
