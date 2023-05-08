import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/helper%20functions/auth_methods.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:instagram_clone/widgets/profile_button.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  //created global variable for userdata.
  var userData = {};
  var postCount = 0;
  var followingCount = 0;
  var followerCount = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getUserData();
  }

//fetching user data from firestore
  void getUserData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var fetchedData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      isFollowing = fetchedData
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      setState(() {
        userData = fetchedData.data()!;
        followerCount = fetchedData.data()!['followers'].length;
        followingCount = fetchedData.data()!['following'].length;
        postCount = postSnap.docs.length;
        isLoading = false;
      });
    } on PlatformException catch (err) {
      Toast.show(err.message!, gravity: Toast.bottom, duration: 2);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserMethods>(context, listen: false).currentUser;
    return isLoading
        ? Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData['userName'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded)
                ],
              ),
              // actions: const [Icon(Icons.menu)],
            ),

            endDrawer: Drawer(
                backgroundColor: mobileBackgroundColor,
                child: Column(
                  children: [
                    TextButton(
                        child: const Text('Sign Out'),
                        onPressed: () async {
                          //sign outing user
                          await AuthMethods().signoutUser();
                        }),
                    const Divider()
                  ],
                )),
            //top profile section
            body: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundColor: secondaryColor,
                        backgroundImage: NetworkImage(
                          userData['imageUrl'],
                        ),
                        radius: 40,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _profileReview(postCount, 'Posts'),
                                _profileReview(followerCount, 'Followers'),
                                _profileReview(followingCount, 'Following'),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            currentUser.uid == widget.uid
                                ? Align(
                                    alignment: Alignment.center,
                                    child: ProfileButton(
                                        title: 'Edite Profile',
                                        textColor: primaryColor,
                                        onTap: () {},
                                        color: mobileBackgroundColor,
                                        boderColor: secondaryColor),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      userData['userName'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      userData['bio'],
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  currentUser.uid == widget.uid
                      ? const SizedBox()
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            isFollowing
                                ? ProfileButton(
                                    title: 'Following',
                                    textColor: blueColor,
                                    onTap: () {
                                      FirestoreMethods.followUser(
                                          currentUser.uid, userData['uid']);
                                      setState(() {
                                        followerCount--;
                                        isFollowing = false;
                                      });
                                    },
                                    color: mobileBackgroundColor,
                                    boderColor: blueColor)
                                : ProfileButton(
                                    title: 'Follow',
                                    textColor: primaryColor,
                                    onTap: () {
                                      FirestoreMethods.followUser(
                                          currentUser.uid, userData['uid']);

                                      setState(() {
                                        followerCount++;
                                        isFollowing = true;
                                      });
                                    },
                                    color: blueColor,
                                    boderColor: blueColor),
                            ProfileButton(
                              title: 'Message',
                              textColor: primaryColor,
                              onTap: () {},
                              color: mobileBackgroundColor,
                              boderColor: secondaryColor,
                            )
                          ],
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  DefaultTabController(
                    length: 2, // Number of tabs
                    child: Expanded(
                      child: Column(
                        children: const [
                          TabBar(
                            tabs: [
                              Icon(Icons.photo_library_outlined),
                              Icon(Icons.bookmark)
                            ],
                          ),

                          // Height of the tab bar view
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Add widgets for Tab 1 content
                                ShowUserPosts(),
                                // Add widgets for Tab 2 content
                                Center(child: Text('No Book Marked Item yet!')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _profileReview(int count, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: .5),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        )
      ],
    );
  }
}

class ShowUserPosts extends StatelessWidget {
  const ShowUserPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
       
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return LoadingIndicator();
        }
        return GridView.builder(
          itemCount: snapshot.data!.docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 3),
          itemBuilder: (context, index) => Image.network(
            snapshot.data!.docs[index]['postUrl'],
          ),
        );
      },
    );
  }
}
