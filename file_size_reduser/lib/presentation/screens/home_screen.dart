import 'dart:io';
import 'dart:typed_data';

import 'package:file_size_reduser/data/image_data.dart';
import 'package:file_size_reduser/logic/cubits/image_cubit.dart';
import 'package:file_size_reduser/repo/image_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../logic/cubits/image_state.dart';

class ImageReducerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageCubit(repository: ImageRepository()),
      child: Scaffold(
        appBar: AppBar(title: Text('Image Reducer')),
        body: ImageReducerForm(),
      ),
    );
  }
}

class ImageReducerForm extends StatefulWidget {
  @override
  _ImageReducerFormState createState() => _ImageReducerFormState();
}

class _ImageReducerFormState extends State<ImageReducerForm> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  int _quality = 80; // Default quality value, you can adjust

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  double bytesToMb(int bytes) {
    return bytes / 1048576;
  }

  Future<void> saveImageToGallery(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/reduced_image.jpg');
    await file.writeAsBytes(bytes);

    final result = await ImageGallerySaver.saveFile(file.path);

    if (result["isSuccess"] == true) {
      print("Image saved to gallery successfully");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved to gallery successfully")),
      );
    } else {
      print("Failed to save image to gallery");
    }
  }


  Widget _buildSelectedImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    return SizedBox.shrink(); // return an empty widget if no image
  }

  Widget _buildImageBasedOnState(ImageState state) {
    if (state is ImageLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is ImageReduced) {
      ImageData imageData = state.reducedImage;
      Uint8List uint8list = Uint8List.fromList(imageData.bytes);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 70,
              width: 600,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.orange[100],borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Original Size: ${bytesToMb(imageData.originalSize).toStringAsFixed(2)} MB'),
                  Text('Reduced Size: ${bytesToMb(imageData.reducedSize).toStringAsFixed(2)} MB'),

                ],
              ),
            ),
          ),
          Image.memory(uint8list, height: 200, fit: BoxFit.contain),
          ElevatedButton(
            onPressed: () async {
              await saveImageToGallery(uint8list);
            },
            child: Text("Save to Gallery"),
          )
        ],
      );
    }
    return SizedBox.shrink(); // return an empty widget for other states
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageCubit, ImageState>(
      listener: (context, state) {
        if (state is ImageError) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _buildSelectedImage(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              Slider(
                value: _quality.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _quality = value.toInt();
                  });
                },
                min: 1,
                max: 100,
                label: 'Quality $_quality',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedImage != null) {
                    context.read<ImageCubit>().reduceImage(_selectedImage!, _quality);
                  }
                },
                child: Text('Reduce Image'),
              ),
              SizedBox(height: 20),
              _buildImageBasedOnState(state),
            ],
          ),
        );
      },
    );
  }
}
