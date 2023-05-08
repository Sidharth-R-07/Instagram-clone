import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:instagram_clone/helper%20functions/auth_methods.dart';
import 'package:instagram_clone/pages/login_page.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:image_picker/image_picker.dart';

import '../helper functions/global_functions.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/text_input_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final userNameController = TextEditingController();
  Uint8List? selectedImage;
  bool isLoading = false;
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    userNameController.dispose();
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 30,
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //title image
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  SvgPicture.asset(
                    'assets/images/ic_instagram.svg',
                    colorFilter:
                        const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                    height: 64,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  //title cirecle avatar for select image

                  Stack(
                    children: [
                      selectedImage != null //then show selected image
                          ? CircleAvatar(
                              radius: 64,
                              backgroundColor: primaryColor,
                              backgroundImage: MemoryImage(selectedImage!),
                            )
                          //otherwise show default image
                          : const CircleAvatar(
                              radius: 64,
                              backgroundColor: primaryColor,
                              backgroundImage: AssetImage(
                                  'assets/images/default profile picture.png'),
                            ),
                      Positioned(
                          bottom: 10,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              _openBottomSheet(context);
                            },
                            child: const CircleAvatar(
                              backgroundColor: blueColor,
                              radius: 15,
                              child: Icon(
                                Icons.add_a_photo,
                                color: primaryColor,
                                size: 15,
                              ),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  //text field for user name

                  TextInputField(
                    controller: userNameController,
                    hint: 'Enter user name',
                    validatorFn: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter valid user name!';
                      } else if (val.length < 4) {
                        return 'name must 4 character';
                      }
                    },
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  //text field for email

                  TextInputField(
                    controller: emailController,
                    hint: 'Enter your email',
                    validatorFn: (val) {
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val!) ||
                          val.isEmpty) {
                        return 'Please enter valid email';
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
                      if (val!.isEmpty) {
                        return 'please enter password';
                      } else if (val.length < 6) {
                        return 'password must be 6 character';
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    obscureInput: true,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //text field for bio

                  TextInputField(
                    controller: bioController,
                    hint: 'Enter your bio',
                    validatorFn: (val) {
                      if (val!.isEmpty) {
                        return 'please enter password';
                      } else if (val.length < 10) {
                        return 'bio must be 10 character';
                      }
                    },
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //button for login

                  GestureDetector(
                    //when clicked sign up button then called _trysubmit function
                    onTap: _trySubmit,
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
                      child: isLoading
                          ? LoadingIndicator()
                          : const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
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
                        child: const Text("Have an account? "),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            "Log in",
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

  Future<void> _trySubmit() async {
//get AuthMethod via provider

    final authMethods = Provider.of<AuthMethods>(context, listen: false);

//checking text input fields are valid or Not
    final isValid = formkey.currentState!.validate();
//if the form isValid then procced to sign up
    setState(() => isLoading = true);
    if (isValid) {
//calling sign up method from AuthMethods class.

      if (selectedImage == null) {
        debugPrint('selected image is null');
      }
      await authMethods.signupUser(
          image: selectedImage!,
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          userName: userNameController.text.trim(),
          bio: bioController.text,
          ctx: context);

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  _openBottomSheet(ctx) {
    return showModalBottomSheet(
      context: ctx,
      barrierColor: Colors.transparent,
      backgroundColor: secondaryColor.shade800,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: Text(
                    'Change Profile Picture',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ListTile(
                  onTap: () async {
                    //open camera and take picture

                    final result =
                        await pickImage(ImageSource.camera, context);

//assign the recieving result to global veriable

                    setState(() {
                      selectedImage = result;
                    });
//close the bottom sheet
                    Navigator.pop(ctx);
                  },
                  title: Text('Take a photo',
                      style: Theme.of(context).textTheme.titleLarge),
                  trailing: const Icon(Icons.camera_alt_outlined),
                ),
                ListTile(
                  onTap: () async {
                    //open files and choose a picture
//assign the recieving result to global veriable

                    final result = await pickImage(ImageSource.gallery, ctx);

                    setState(() {
                      selectedImage = result;
                    });
//close the bottom sheet

                    Navigator.pop(ctx);
                  },
                  title: Text('Choose from gallery',
                      style: Theme.of(context).textTheme.titleLarge),
                  trailing: const Icon(Icons.photo_library_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
