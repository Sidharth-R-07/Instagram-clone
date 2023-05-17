import 'package:flutter/material.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/utility/colors.dart';

class ErrorPage extends StatelessWidget {
  final String errorText;

  const ErrorPage({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          Text(errorText),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                    (route) => false);
              },
              child: const Text(
                'retry',
                style: TextStyle(color: blueColor),
              ))
        ]),
      ),
    );
  }
}
