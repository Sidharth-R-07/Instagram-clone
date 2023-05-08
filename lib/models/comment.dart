import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentText;
  final Timestamp createAt;
  final String uid;
  final String userName;
  final String profilePicture;
  final String postId;
  final String commentId;
  final List likes;

  Comment({
    required this.commentText,
    required this.createAt,
    required this.uid,
    required this.userName,
    required this.profilePicture,
    required this.postId,
    required this.commentId,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'commentText': commentText,
        'createAt': createAt,
        'uid': uid,
        'userName': userName,
        'profilePicture': profilePicture,
        'postId': postId,
        'commentId': commentId,
        'likes': likes
      };
}
