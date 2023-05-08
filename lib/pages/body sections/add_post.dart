import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/helper%20functions/firestore_methods.dart';
import 'package:instagram_clone/helper%20functions/global_functions.dart';
import 'package:instagram_clone/helper%20functions/user_methods.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utility/dimansions.dart';
import 'package:instagram_clone/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../utility/colors.dart';

class AddPostBody extends StatefulWidget {
  const AddPostBody({super.key});

  @override
  State<AddPostBody> createState() => _AddPostBodyState();
}

class _AddPostBodyState extends State<AddPostBody> {
  Uint8List? selectedImage;
  final captionController = TextEditingController();
  bool isLoading = false;

//this clear image function for clearing selected image
  _clearImage() {
    setState(() {
      selectedImage = null;
    });
  }

  @override
  void dispose() {
    super.dispose();

    captionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserMethods>(context).currentUser;
    final size=MediaQuery.of(context).size;

    return selectedImage == null ? selectPost(size) : previewPost(user);
  }

  selectPost(Size size) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio:size.width>webScreenSize?5/2 : 10 / 5,
            child: GestureDetector(
              onTap: () async {
                final pickedImage =
                    await pickImage(ImageSource.gallery, context);

                setState(() {
                  selectedImage = pickedImage;
                });
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: secondaryColor),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.upload_rounded,
                        size: 80,
                      ),
                      Text(
                        'Choose from gallery',
                        style: TextStyle(letterSpacing: 1),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  previewPost(User user) => Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _clearImage,
          ),
          title: const Text('Share post'),
          centerTitle: false,
          actions: [
            TextButton(
                style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                onPressed: () => _postImage(
                      imageUrl: user.imageUrl,
                      uid: user.uid,
                      userName: user.userName,
                    ),
                child: selectedImage == null
                    ? const SizedBox()
                    : isLoading
                        ? LoadingIndicator(
                            color: blueColor,
                          )
                        : const Text(
                            'Post',
                            style: TextStyle(letterSpacing: 1),
                          ))
          ],
        ),

        //checking if selected image is null then show some text
        body: selectedImage == null
            ? const Center(
                child: Text(
                'Opps! Something went wrong!\n Try again...',
                textAlign: TextAlign.center,
              ))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: captionController,
                      maxLines: 4,
                      maxLength: 101,
                      decoration: const InputDecoration(
                        hintText: 'write a  caption',
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: MediaQuery.of(context).size.height * 0.17,
                      child: Image.memory(
                        selectedImage!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
      );

//send post function
  Future<void> _postImage({
    required String userName,
    required String imageUrl,
    required String uid,
  }) async {
    setState(() {
      isLoading = true;
    });

    if (selectedImage == null) {
      debugPrint('Selected image is null');
      return;
    }
    final result = await FirestoreMethods.uploadPost(
        captionController.text, uid, selectedImage!, userName, imageUrl);
    captionController.clear();
    selectedImage=null;
    setState(() {
      isLoading = false;
    });
    Toast.show(result, duration: 2);
    debugPrint(result);

    //the post will stored successfully.then clear the image.
    _clearImage();
  }
}
