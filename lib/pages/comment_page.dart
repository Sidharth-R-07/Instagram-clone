import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../widgets/comment_card.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _commentController = TextEditingController();
  bool isLoading = false;
  @override
  void dispose() {
    super.dispose();

    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserMethods>(context, listen: false).currentUser;
    return Scaffold(
      //header app bar section
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('comments'),
        centerTitle: false,
      ),

      //body section for showing comment list

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('ERROR FOUND:${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('There is no comment yet!'),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                  CommentCard(snapshot: snapshot.data!.docs[index]),
            );
          }
          return const SizedBox();
        },
      ),

      //footer section for write user comment
      bottomNavigationBar: SafeArea(
          child: Container(
        height: kToolbarHeight,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.imageUrl),
              backgroundColor: secondaryColor,
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                      hintText: 'write your comment',
                      border: InputBorder.none),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
//posting comment function

                // setState(() {
                //   isLoading = true;
                // });

                if (_commentController.text.isEmpty) {
                  return;
                }

                final result = await FirestoreMethods.postComment(
                  user.uid,
                  user.imageUrl,
                  widget.postId,
                  _commentController.text,
                  user.userName,
                );
                _commentController.clear();
                FocusManager.instance.primaryFocus?.unfocus();

                // setState(() {
                //   isLoading = false;
                // });
                Toast.show(result, gravity: Toast.bottom, duration: 2);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: isLoading
                    ? LoadingIndicator(
                        color: blueColor,
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(color: blueColor, letterSpacing: .5),
                      ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
