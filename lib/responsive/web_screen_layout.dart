import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../helper functions/auth_methods.dart';
import '../helper functions/user_methods.dart';
import '../pages/body sections/add_post.dart';
import '../pages/body sections/home_body.dart';
import '../pages/body sections/profile_page.dart';
import '../pages/body sections/search_user.dart';
import '../utility/colors.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _selectedTab = 0;
  bool isLoading = false;
  late PageController _pageController;
  List<Widget> bodyWidget = [
    const HomeBody(),
    const SearchBody(),
    const AddPostBody(),
    ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid),
  ];

  void onTabClick(int indx) {
    setState(() {
      _selectedTab = indx;
    });
    _pageController.jumpToPage(_selectedTab);
  }

//fetch data from firestore
  void fetchData(BuildContext ctx) async {
    setState(() {
      isLoading = true;
    });
    //fetch current user data from firebase firestore
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await AuthMethods().signoutUser();
    } else {
      Provider.of<UserMethods>(ctx, listen: false).getCurrentUser();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _pageController = PageController();
    //fetch data from firebase
    fetchData(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
    if (!mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: SvgPicture.asset(
            'assets/images/ic_instagram.svg',
            colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
            height: 30,
          ),
          actions: [
            // InkWell(
            //   onTap: () {
            //     //open Chat room screen
            //   },
            //   child: Container(
            //       padding: const EdgeInsets.only(right: 8),
            //       child: Image.asset(
            //         'assets/images/send.png',
            //         color: primaryColor,
            //         height: 20,
            //         width: 20,
            //       )),
            // ),
            IconButton(
              onPressed: () => onTabClick(0),
              icon: Icon(
                Icons.home,
                color: _selectedTab == 0 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () => onTabClick(1),
              icon: Icon(
                Icons.search,
                color: _selectedTab == 1 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () => onTabClick(2),
              icon: Icon(
                Icons.add_box_rounded,
                color: _selectedTab == 2 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () => onTabClick(3),
              icon: Icon(
                Icons.person,
                color: _selectedTab == 3 ? primaryColor : secondaryColor,
              ),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: onTabClick,
          children: bodyWidget,
        ));
  }
}
