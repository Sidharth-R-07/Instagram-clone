import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/helper%20functions/auth_methods.dart';
import 'package:instagram_clone/pages/signup_page.dart';

import 'package:instagram_clone/utility/colors.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../utility/dimansions.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/text_input_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false; //this bool for loading indicator

//created variable for showing error in screen
  String displayError = '';

  //creating key for validating form
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    isLoading = false;
    emailController.dispose();
    passwordController.dispose();
    displayError = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ToastContext().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: size.width > webScreenSize
                ? EdgeInsets.symmetric(horizontal: size.width / 3)
                :const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 50,
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //title image
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  Image.asset(
                    'assets/images/instagram logo.png',
                    height: 64,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SvgPicture.asset(
                    'assets/images/ic_instagram.svg',
                    colorFilter:
                        const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                    height: 64,
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  //text field for email

                  TextInputField(
                    controller: emailController,
                    hint: 'Enter your email',
                    validatorFn: (val) {
                      if (val == null ||
                          val.isEmpty ||
                          !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val)) {
                        return 'Enter valid  email!';
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //text field for password
                  TextInputField(
                    controller: passwordController,
                    hint: 'Enter your password',
                    validatorFn: (val) {
                      if (val!.isEmpty || val.length < 5) {
                        return 'Enter valid password';
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    obscureInput: true,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //button for login

                  GestureDetector(
                    //when button clicked trying to login
                    onTap: _tryLogin,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                        color: blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                      ),
                      child: isLoading //checking loading if is it's true
                          ? LoadingIndicator()
                          : const Text('Log in'),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  Text(
                    displayError,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.redAccent),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Don't have an account?"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//login onpressed function
  Future<void> _tryLogin() async {
    //get AuthMethods form provider

    final authMethods = Provider.of<AuthMethods>(context, listen: false);
    setState(() => isLoading = true);
//checking form is valid or not
    final isValid = formkey.currentState!.validate();
//if the form is valid then procced to login
    if (isValid) {
      //using authmethods to calling login function

      final result = await authMethods.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          ctx: context);
      if (result == null) {
        return;
      }
      setState(() {
        displayError = result;
      });
      // Toast.show(result, duration: 2, gravity: Toast.bottom);
      debugPrint('result:$result');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}
