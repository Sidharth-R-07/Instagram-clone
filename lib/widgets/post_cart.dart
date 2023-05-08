import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/pages/comment_page.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  const PostCard({super.key, required this.snapshot});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentCount = 0;
//created method for date time convert to time based
  String _postedDateTime(DateTime createAt) {
    final differnce = DateTime.now().difference(createAt);

    if (differnce.inSeconds < 60) {
      return '${differnce.inSeconds} seconds ago';
    }
    if (differnce.inSeconds > 60 && differnce.inMinutes < 60) {
      debugPrint('Date in Minite:${differnce.inMinutes}');
      return '${differnce.inMinutes} minites ago';
    }
    if (differnce.inMinutes > 60 && differnce.inHours < 24) {
      debugPrint('Date in Hourse:${differnce.inHours}');

      return ' ${differnce.inHours} hours ago';
    }
    return DateFormat.yMMMd().format(createAt);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserMethods>(context, listen: false).currentUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          //post header section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      NetworkImage(widget.snapshot['profileImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.snapshot['userName']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: .5),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    //show drop down to edite post
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          // post image section

          GestureDetector(
            onDoubleTap: () async {
              //checking post is already liked or not
              //the post not liked then showing the animation.otherwise not showing the animation
              if (!widget.snapshot['likes'].contains(user.uid)) {
                setState(() {
                  isLikeAnimating = true;
                });
              }
              //store the value to firestore
              await FirestoreMethods.togglePostLike(widget.snapshot['postId'],
                  user.uid, widget.snapshot['likes']);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: double.infinity,
                  child: Image.network(
                    widget.snapshot['postUrl'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return LoadingIndicator();
                    },
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? .9 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 300),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: primaryColor,
                      size: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //footer section
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snapshot['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods.togglePostLike(
                        widget.snapshot['postId'],
                        user.uid,
                        widget.snapshot['likes']);
                  },
                  icon: widget.snapshot['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border_rounded,
                          color: primaryColor,
                        ),
                ),
              ),
              //comment section
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CommentPage(postId: widget.snapshot['postId']),
                  ));
                },
                icon: const Icon(
                  Icons.comment,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      icon: const Icon(Icons.bookmark_border_rounded),
                      onPressed: () {}),
                ),
              ),
            ],
          ),

          //show caption and comments count

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.snapshot['likes'].length}  likes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                            text: '${widget.snapshot['userName']}  ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: widget.snapshot['caption'],
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    //goto Comment page

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CommentPage(postId: widget.snapshot['postId']),
                    ));
                  },
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.snapshot['postId'])
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data!.docs.isEmpty) {
                        return const SizedBox();
                      }

                      if (snapshot.hasError) {
                        debugPrint('ERROR FOUND IN COMMENT:${snapshot.error}');
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'view all ${snapshot.data!.docs.length} comments',
                          style: const TextStyle(
                              fontSize: 15, color: secondaryColor),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _postedDateTime(widget.snapshot['createAt'].toDate()),
                    style: const TextStyle(fontSize: 15, color: secondaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
