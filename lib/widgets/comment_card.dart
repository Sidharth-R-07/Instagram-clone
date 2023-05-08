import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/global_functions.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expandable_text/expandable_text.dart';

class CommentCard extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  const CommentCard({super.key, required this.snapshot});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserMethods>(context, listen: false).currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snapshot['profilePicture']),
            backgroundColor: secondaryColor,
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                    Text(
                         widget.snapshot['userName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                           ExpandableText(
        widget.snapshot['commentText'],
        expandText: 'show more',
        collapseText: 'show less',
        maxLines: 2,
        linkColor: Colors.blue,
    ),
               
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      DateFormat.yMMMd()
                          .format(widget.snapshot['createAt'].toDate()),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LikeAnimation(
                isAnimating: widget.snapshot['likes'].contains(user.uid),
                duration: const Duration(milliseconds: 200),
                smallLike: true,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 10,
                  icon: Icon(
                    Icons.favorite,
                    size: 16,
                    color: widget.snapshot['likes'].contains(user.uid)
                        ? Colors.red
                        : primaryColor,
                  ),
                  onPressed: () async {
                    FirestoreMethods.toggleCommentLike(
                        widget.snapshot['commentId'],
                        widget.snapshot['postId'],
                        user.uid,
                        widget.snapshot['likes']);
                  },
                ),
              ),
              Text(
                widget.snapshot['likes'].length == 0
                    ? ''
                    : '${widget.snapshot['likes'].length} likes',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),

          //cheking commented by current user or not
          //if the comment by current user then show delete option
          user.uid == widget.snapshot['uid']
              ? PopupMenuButton(
                  padding: EdgeInsets.zero,
                  onSelected: _deleteComment,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    )
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  void _deleteComment(String value) async {
    if (value == 'delete') {
      debugPrint('comment delete function called');

      conformationBottomSheet(
        context,
        'Do you want to delete this comment?',
        //pass  the delete function
        () {
          //Thene call delete comment function from FirestoreMethods

          FirestoreMethods.deletComment(
            widget.snapshot['commentId'],
            widget.snapshot['postId'],
          );
        },
      );
    }

    return;
  }
}
