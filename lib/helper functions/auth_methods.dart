import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/storage_methods.dart';
import 'package:toast/toast.dart';
import '../models/user.dart' as usermodel;
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';

class AuthMethods with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  Future<String> signupUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List image,
    required BuildContext ctx,
    // required Uint8List file,
  }) async {
    String result = 'Some error occured!';

    try {
//register new user

      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      debugPrint('1111111111111111');
//store image to firebase storage

      final photoUrl =
          await StorageMethods.uploadImage('profile_pictures', image, false);
      debugPrint('2222222222222');

//create user from UserModel
      final user = usermodel.User(
          userName: userName,
          uid: credential.user!.uid,
          bio: bio,
          imageUrl: photoUrl,
          following: [],
          followers: [],
          createAt: Timestamp.now());
      debugPrint('33333333333333');

//then.Store user data to cloud firestore

      FirestoreMethods.storeUserData(user, credential.user!.uid).then((value) {
        result = 'Sign up successfull';

        Toast.show(result, gravity: Toast.bottom, duration: 2);

        return Navigator.of(ctx).pushReplacement(MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
                webScreen: WebScreenLayout(),
                mobileScreen: MobileScreenLayout())));
      });
      debugPrint('4444444444444444');

      result = 'Sign up successfull';
    } on FirebaseAuthException catch (err) {
      result = err.message!;
      Toast.show(result, gravity: Toast.bottom, duration: 2);

      debugPrint('555555555555555555');

      debugPrint('Error found in SignUp:$err');
    } on FirebaseException catch (err) {
      result = 'Something went wrong,Try again!';
      Toast.show(result, gravity: Toast.bottom, duration: 2);

      debugPrint('666666666666666666666666666666');

      debugPrint(err.toString());
    }

    return result;
  }

//login function for login to user
  Future<String> loginUser(
      {required String email,
      required String password,
      required BuildContext ctx}) async {
//this result variable for result showing for users
    String result = '';
//login user

    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        // result = 'Log in successfull';

        //showing result for user in toast
        Toast.show('Log in successfull', gravity: Toast.bottom, duration: 2);
        debugPrint(result);
        return Navigator.of(ctx).pushReplacement(MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
                webScreen: WebScreenLayout(),
                mobileScreen: MobileScreenLayout())));
      });
    } on FirebaseAuthException catch (err) {
      //get error from firebaseAuth excepetion and store to variable
      result = err.message!;
    } on FirebaseException catch (err) {
      //catching other errors printing to console
      debugPrint(err.message);
      debugPrint(err.toString());
    }

    return result;
  }

  //signout user functions

  Future<String> signoutUser() async {
    String result = 'Something went wrong!';

    try {
      await _auth.signOut();
      result = 'Sign out successfull';
    } on FirebaseAuthException catch (err) {
      result = err.message!;
    } catch (err) {
      debugPrint('errror found:$err');
    }

    return result;
  }
}
