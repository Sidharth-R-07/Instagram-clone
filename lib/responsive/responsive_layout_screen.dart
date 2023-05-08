import 'package:flutter/material.dart';

import '../utility/dimansions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget webScreen;
  final Widget mobileScreen;

  const ResponsiveLayout(
      {super.key, required this.webScreen, required this.mobileScreen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, contrain) {
      if (contrain.maxWidth > webScreenSize) {
        //web Screen
        return webScreen;
      }
      return mobileScreen;
      //Mobile screen
    });
  }
}
