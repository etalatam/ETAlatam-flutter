import 'dart:io';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPicturePage extends StatefulWidget {
  UploadPicturePage({this.student_id});

  final int? student_id;

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

    final url = Uri.parse(
        "${apiURL}mobile_api"); // Replace with your server's upload endpoint
    var request = http.MultipartRequest('POST', url)
      ..fields['token'] = storage.getItem('token')
      ..fields['student_id'] = widget.student_id.toString()
      ..fields['model'] = 'Student.upload_picture';
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

  void _onWillPop(BuildContext context) async {
    // Show a confirmation dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User doesn't want to go back
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // User confirmed, proceed with back navigation
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (oldPop) => _onWillPop(context),
      child: Scaffold(
        body: Center(
          child: _imageFile == null
              ? Text('No image selected.')
              : Image.file(_imageFile!),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: getImage,
              tooltip: 'Pick Image',
              child: Icon(Icons.photo_library),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: uploadImage,
              tooltip: 'Upload Image',
              child: Icon(Icons.upload),
            ),
          ],
        ),
      ),
    );
  }
}
