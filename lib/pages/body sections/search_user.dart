import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/pages/body%20sections/profile_page.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../models/user.dart' as usermodel;
import '../../utility/colors.dart';

import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';

import '../../utility/dimansions.dart';

class SearchBody extends StatefulWidget {
  const SearchBody({super.key});

  @override
  State<SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  final _searchController = TextEditingController();

  bool isSearching = false;
  List<usermodel.User> _searchResults = [];

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search user',
            fillColor: secondaryColor,
            border: InputBorder.none,
          ),
          onFieldSubmitted: (_) async {
            //check when the input has value
            if (_searchController.text.isNotEmpty) {
              _searchResults =
                  await FirestoreMethods.searchUser(_searchController.text);
              setState(() {
                isSearching = true;
              });
            }
          },
        ),
      ),
      backgroundColor: mobileBackgroundColor,
      body: isSearching
          ? _showSearchResult()

          //if user not searching then shows posts
          : _showPosts(size),
    );
  }

  Widget _showPosts(Size size) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
      child: FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('There is no data found!'),
            );
          }

          return StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            itemCount: snapshot.data!.docs.length,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            staggeredTileBuilder: (index) => size.width > webScreenSize
                ? StaggeredTile.count(
                    (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                : StaggeredTile.count(
                    (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
            itemBuilder: (context, index) {
              final postSnap = snapshot.data!.docs[index];

              return Image.network(
                postSnap['postUrl'],
                fit: BoxFit.fill,
              );
            },
          );
          
        },
      ),
    );
  }

  Widget _showSearchResult() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('NO result found'),
      );
    }

    return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          ValueNotifier<bool> isFollowing = ValueNotifier(
              user.followers.contains(FirebaseAuth.instance.currentUser!.uid));

          return ValueListenableBuilder(
            valueListenable: isFollowing,
            builder: (context, isFlow, _) => ListTile(
              onTap: () {
                //goto profile page
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: user.uid)));
              },
              leading: CircleAvatar(
                backgroundColor: secondaryColor,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
              title: Text(user.userName),
              trailing: isFlow
                  ? OutlinedButton(
                      onPressed: () {
                        isFollowing.value = false;

                        FirestoreMethods.followUser(
                            FirebaseAuth.instance.currentUser!.uid, user.uid);
                      },
                      child: const Text('Following'))
                  : ElevatedButton(
                      onPressed: () {
                        isFollowing.value = true;

                        FirestoreMethods.followUser(
                            FirebaseAuth.instance.currentUser!.uid, user.uid);
                      },
                      child: const Text('Follow'),
                    ),
            ),
          );
        });
    /*
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where(
            'userName',
            isGreaterThanOrEqualTo: _searchController.text.trim(),
          )
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('There is no result found'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // get users snapshot
            final userSnap = snapshot.data!.docs[index];
            return ListTile(
              onTap: () {
                //goto profile page
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: userSnap['uid'])));
              },
              leading: CircleAvatar(
                backgroundColor: secondaryColor,
                backgroundImage: NetworkImage(userSnap['imageUrl']),
              ),
              title: Text(userSnap['userName']),
            );
          },
        );
      },
    );

  */
  }
}
