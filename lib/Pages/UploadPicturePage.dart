import 'dart:io';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPicturePage extends StatefulWidget {
  const UploadPicturePage({super.key});

  @override
  _UploadPicturePageState createState() => _UploadPicturePageState();
}

class _UploadPicturePageState extends State<UploadPicturePage> {
  final picker = ImagePicker();
  File? _imageFile;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future uploadImage() async {
    if (_imageFile == null) {
      // No image selected
      return;
    }

    final driverId = await storage.getItem('driver_id');

    final url = Uri.parse(
        "${apiURL}mobile_api"); // Replace with your server's upload endpoint
    var request = http.MultipartRequest('POST', url)
      ..fields['token'] = storage.getItem('token')
      ..fields['driver_id'] = driverId.toString()
      ..fields['model'] = 'Driver.upload_picture';
    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        String responseText = await response.stream.bytesToString();
        goback(responseText);
        return responseText;
      } else {
        // Handle error
        return lang.translate('Error');
      }
    } catch (error) {
      return lang.translate('Error $error');
    }
  }

  goback(response) {
    Navigator.pop(context, response);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    // Show a confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User doesn't want to go back
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // User confirmed, proceed with back navigation
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    // Return the user's confirmation choice
    return confirm;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (old) => _onWillPop(context),
      child: Scaffold(
        body: Center(
          child: _imageFile == null
              ? const Text('No image selected.')
              : Image.file(_imageFile!),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: getImage,
              tooltip: 'Pick Image',
              child: const Icon(Icons.photo_library),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: uploadImage,
              tooltip: 'Upload Image',
              child: const Icon(Icons.upload),
            ),
          ],
        ),
      ),
    );
  }
}
