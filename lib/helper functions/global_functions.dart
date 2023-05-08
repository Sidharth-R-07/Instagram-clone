import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:toast/toast.dart';

//image pick function
pickImage(ImageSource source, BuildContext ctx) async {
  try {
    final imagepicker = ImagePicker();
    final file = await imagepicker.pickImage(source: source);

    if (file != null) {
      return await file.readAsBytes();
    }
    Toast.show('No image selected', gravity: Toast.bottom);
  } on PlatformException catch (err) {
    debugPrint('Erron in picked image:${err.message}');
  }
}

//open bottom sheet for conformation

conformationBottomSheet(BuildContext ctx, String title, Function() conformFN) {
  showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    builder: (context) => Container(
      height: 200,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  //close bottom sheet
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'No',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  conformFN();
                  //close bottom sheet
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Yes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: blueColor),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
