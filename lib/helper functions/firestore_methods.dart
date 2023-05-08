import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/helper%20functions/storage_methods.dart';
import 'package:instagram_clone/models/post.dart';
import '../models/comment.dart';
import '../models/user.dart' as usermodel;
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  static final _firestore = FirebaseFirestore.instance;

  static Uuid uuid = const Uuid();

//storing user data from sign up section
  static Future<void> storeUserData(usermodel.User user, String uid) async {
    await _firestore.collection('users').doc(uid).set(user.toJson());
  }

//upload post to firestore
  static Future<String> uploadPost(
    String caption,
    String uid,
    Uint8List file,
    String userName,
    String profileImage,
  ) async {
    String result = 'some error occured!';

    try {
      final photoUrl = await StorageMethods.uploadImage('posts', file, true);
      final newPost = Post(
        caption: caption,
        userName: userName,
        uid: uid,
        postId: uuid.v1(),
        postUrl: photoUrl,
        profileImage: profileImage,
        createAt: Timestamp.now(),
        likes: [],
      );

      await _firestore
          .collection('posts')
          .doc(newPost.postId)
          .set(newPost.toJson());
      result = 'Post uploaded';
    } on PlatformException catch (err) {
      result = err.message!;
    } catch (err) {
      result = err.toString();
    }

    return result;
  }

//toggel like status and store to firestore
  static Future<void> togglePostLike(
      String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  static Future<String> postComment(
    String uid,
    String profilePic,
    String postId,
    String comment,
    String userName,
  ) async {
    String result = 'some error occured!';
    final commentId = const Uuid().v1();

    final newComment = Comment(
      commentId: commentId,
      commentText: comment,
      createAt: Timestamp.now(),
      postId: postId,
      profilePicture: profilePic,
      uid: uid,
      userName: userName,
      likes: [],
    );
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(newComment.toJson());
      result = 'Commented!';
    } on PlatformException catch (err) {
      result = err.message!;
    } catch (err) {
      result = 'Something wentwrong!try again...';
      debugPrint(err.toString());
    }

    return result;
  }

  //toggel comment like status and store to firestore
  static Future<void> toggleCommentLike(
      String commentId, String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }
//delete comment function

  static Future<void> deletComment(String commentId, String postId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  //follow user methods

  static Future<void> followUser(String uid, String followId) async {
    try {
      final snap = await _firestore.collection('users').doc(uid).get();

      List followingList = snap.data()!['following'];

      if (followingList.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

//search user result function
  static Future<List<usermodel.User>> searchUser(String inputText) async {
    final snap = await _firestore
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: inputText)
        .get();

    final userData = snap.docs
        .map<usermodel.User>((data) => usermodel.User(
            userName: data['userName'],
            uid: data['uid'],
            bio: data['bio'],
            imageUrl: data['imageUrl'],
            following: data['following'],
            followers: data['followers'],
            createAt: data['createAt']))
        .toList();

    debugPrint(userData.toString());
    return userData;
  }
}
