import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/helper%20functions/auth_methods.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../pages/body sections/add_post.dart';
import '../pages/body sections/home_body.dart';
import '../pages/body sections/profile_page.dart';
import '../pages/body sections/search_user.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
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
    ToastContext().init(context);

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? LoadingIndicator()
            : PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: bodyWidget,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              backgroundColor: mobileBackgroundColor,
              icon: Icon(Icons.home),
              label: ''),
          BottomNavigationBarItem(
              backgroundColor: mobileBackgroundColor,
              icon: Icon(Icons.search),
              label: ''),
          BottomNavigationBarItem(
              backgroundColor: mobileBackgroundColor,
              icon: Icon(Icons.add_box),
              label: ''),
          BottomNavigationBarItem(
              backgroundColor: mobileBackgroundColor,
              icon: Icon(Icons.person),
              label: ''),
        ],
        currentIndex: _selectedTab,
        onTap: onTabClick,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        backgroundColor: mobileBackgroundColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }


}
