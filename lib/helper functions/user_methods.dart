import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart' as usermodel;

class UserMethods with ChangeNotifier {
  usermodel.User? _user;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

//get current user
  usermodel.User get currentUser => _user!;

//getting current user details from firestore.

  Future<void> getCurrentUser() async {
    final currentUserUid = _auth.currentUser!.uid;
    final userData =
        await _firestore.collection('users').doc(currentUserUid).get();
    final user =
        usermodel.User.fromJson(userData.data() as Map<String, dynamic>);

    _user = user;
    notifyListeners();
    debugPrint('user Name: ${user.userName}');
  }
}
