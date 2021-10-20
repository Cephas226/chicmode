{bcrypt}$2a$10$draQiN7UXql/MpwGsyx8M.mQiJXYSx.qyx765wut7dYS6Y5nVq1Yy

  
  https://we.tl/t-ztb1sxRXKz
https://stackoverflow.com/questions/67499115/flutter-use-network-images-protected-with-basic-auth

  Widget rowAction(actualiteList,index,idx,url) {
    return Row( 
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.hand_thumbsdown,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      counterDisLike--;
                    });
                  },
                ),
                counterDisLike > 0 ? Text(counterDisLike.toString()) : Text("0")
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.hand_thumbsup,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      counterLike++;
                    });
                  },
                ),
                counterLike > 0 ? Text(counterLike.toString()) : Text("0")
              ],
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.comment,
            color: Colors.black54,
          ),
          onPressed: () {
                 Get.to(()=>Scaffold(

                   body: CarouselSlider.builder(
                                        itemCount: actualiteList.length,
                                        options: CarouselOptions(
                                          height: 800,
                                          scrollDirection: Axis.vertical,
                                          initialPage: index,
                                          viewportFraction: 1,
                                          aspectRatio: 16 / 9,
                                          enableInfiniteScroll: false,
                                          autoPlay: false,
                                        ),
                                        itemBuilder: (BuildContext context, int itemIndex,
                                            int pageViewIndex) =>
                                            Stack(
                                              children: <Widget>[
                                                Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadiusDirectional.circular(20)),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(0.0),
                                                    height: double.infinity,
                                                    color: Color(0xFFF70759),
                                                    child: PhotoHero(
                                                      photoWiget:  Material(
                                                                color: Colors.transparent,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                          Get.back();
                                                                        },
                                                                   child:Container(
                                                                          decoration: BoxDecoration(
                                                                            image: DecorationImage(
                                                                              image: NetworkImage(
                                                                                    '${actualiteList[index].files[idx].uri.replaceAll('localhost', '192.168.1.15')}',headers: {"Authorization": "Bearer " + response!.accessToken.toString()}),
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                            shape: BoxShape.rectangle,
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                    ),
                                                  ),
                                                )]))));
          },
        ),
        IconButton(
          icon: Icon(
            CupertinoIcons.share,
            color: Colors.black54,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
