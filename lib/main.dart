import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/auth_methods.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/pages/login_page.dart';

import 'utility/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAF5yitqI2MZOWv54pL7OpJdiEK8_oN7aI',
        appId: '1:916978365873:web:bf9bd1cb949e26af9b3990',
        messagingSenderId: '916978365873',
        projectId: 'instagram-clone-c3c95',
        storageBucket: 'instagram-clone-c3c95.appspot.com',
      ),
    );
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthMethods(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserMethods(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram clone',

        theme: ThemeData(
          fontFamily: 'Sans',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),

        home: AnimatedSplashScreen(
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: mobileBackgroundColor,
          splash: Center(
            child: Image.asset(
              'assets/images/instagram logo.png',
              fit: BoxFit.contain,
            ),
          ),
          duration: 1000,
          nextScreen: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return const ResponsiveLayout(
                      webScreen: WebScreenLayout(),
                      mobileScreen: MobileScreenLayout());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }

              return const LoginPage();
            },
          ),
        ),

        // home: const ResponsiveLayout(
        //     mobileScreen: MobileScreenLayout(), webScreen: WebScreenLayout()),
      ),
    );
  }
}
