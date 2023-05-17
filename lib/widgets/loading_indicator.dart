import 'package:flutter/material.dart';

import '../utility/colors.dart';

// ignore: must_be_immutable
class LoadingIndicator extends StatelessWidget {

  Color? color;
  
   LoadingIndicator({ this.color=primaryColor ,  super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
