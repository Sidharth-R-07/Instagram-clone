import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String caption;
  final String userName;
  final String uid;
  final String postId;
  final String postUrl;
  final String profileImage;

  final Timestamp createAt;
  final List  likes;

  Post({
    required this.caption,
    required this.userName,
    required this.uid,
    required this.postId,
    required this.postUrl,
    required this.profileImage,
    required this.createAt,
    required this.likes,
  });

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      userName: json['userName'],
      uid: json['uid'],
      caption: json['caption'],
      postId: json['postId'],
      postUrl: json['postUrl'],
      profileImage: json['profileImage'],
      createAt: json['createAt'],
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'uid': uid,
        'createAt': createAt,
        'caption': caption,
        'postId': postId,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'likes': likes,
      };
}
