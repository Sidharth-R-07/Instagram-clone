import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userName;
  final String uid;
  final String bio;
  final String imageUrl;
  final List following;
  final List followers;
  final Timestamp createAt;

  User({
    required this.userName,
    required this.uid,
    required this.bio,
    required this.imageUrl,
    required this.following,
    required this.followers,
    required this.createAt,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
        userName: json['userName'],
        uid: json['uid'],
        bio: json['bio'],
        imageUrl: json['imageUrl'],
        following: json['following'],
        followers: json['followers'],
        createAt: json['createAt']);
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'uid': uid,
        'createAt': createAt,
        'bio': bio,
        'followers': followers,
        'imageUrl': imageUrl,
        'following': following,
      };
}
