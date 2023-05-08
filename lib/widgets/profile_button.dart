import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  final Color color;
  final Color boderColor;
  final Color textColor;
  const ProfileButton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.color,
      required this.boderColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 160,
        // height: 32,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: boderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          title,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
