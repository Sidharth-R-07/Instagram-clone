import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static const uuid = Uuid();
  static final currentuser = FirebaseAuth.instance;
//adding image to firrbase storage
  static Future<String> uploadImage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(currentuser.currentUser!.uid);
    if (isPost) {
      ref = ref.child(uuid.v1());
    }
    debugPrint('Storage:1111111111');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;

    final dowloadedUrl = await snap.ref.getDownloadURL();

    return dowloadedUrl;
  }
}
