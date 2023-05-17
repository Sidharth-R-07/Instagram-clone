import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/pages/error_page.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';

import '../../utility/dimansions.dart';
import '../../widgets/post_cart.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: size.width > webScreenSize
          ? webBackgroundColor
          : mobileBackgroundColor,
      appBar: size.width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              title: SvgPicture.asset(
                'assets/images/ic_instagram.svg',
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 30,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                InkWell(
                  onTap: () {
                    //open Chat room screen
                  },
                  child: Container(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        'assets/images/send.png',
                        color: primaryColor,
                        height: 20,
                        width: 20,
                      )),
                )
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorPage(errorText: snapshot.error.toString());
          }

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: size.width > webScreenSize ? webScreenSize * 0.3 : 0,
            ),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final postSnap = snapshot.data!.docs[index];

                return PostCard(snapshot: postSnap);
              },
            ),
          );
        },
      ),
    );
  }
}
