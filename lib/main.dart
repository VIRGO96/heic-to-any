import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEIC to JPG Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HeicToJpgConverter(),
    );
  }
}

class HeicToJpgConverter extends StatefulWidget {
  const HeicToJpgConverter({super.key});

  @override
  _HeicToJpgConverterState createState() => _HeicToJpgConverterState();
}

class _HeicToJpgConverterState extends State<HeicToJpgConverter> {
  File? _image;

  Future<void> pickAndConvertImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    if (pickedFile.path.toLowerCase().endsWith('.heic')) {
      try {
        final jpgPath = await HeifConverter.convert(pickedFile.path);
        if (jpgPath != null) {
          setState(() => _image = File(jpgPath!));
        } else {
          debugPrint("Conversion failed: jpgPath is null");
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Conversion failed: $e")));
      }
    } else {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> saveImage() async {
    if (_image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final newPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _image!.copy(newPath);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Image saved to: $newPath")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HEIC to JPG Converter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickAndConvertImage,
              child: const Text("Pick HEIC File"),
            ),
            if (_image != null)
              ElevatedButton(
                onPressed: saveImage,
                child: const Text("Save JPG"),
              ),
          ],
        ),
      ),
    );
  }
}
