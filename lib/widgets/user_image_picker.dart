import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});
  final void Function(File pickedImage) onPickedImage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  void _pickImage() async {
    final pickedImage = await showDialog<XFile>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("How to get an image?"),
            children: [
              TextButton.icon(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        imageQuality: 50,
                        maxWidth: 150);
                    Navigator.pop(context, image);
                  },
                  label: Text("Use Camera"),
                  icon: Icon(Icons.camera)),
              TextButton.icon(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 50,
                        maxWidth: 150);
                    Navigator.pop(context, image);
                  },
                  label: Text("Brows Gallery"),
                  icon: Icon(Icons.image_search))
            ],
          );
        });

    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          child: _pickedImageFile == null ? Icon(Icons.person, size: 40) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            label: Text("Add your Avatar"),
            icon: Icon(Icons.add_a_photo)),
      ],
    );
  }
}
