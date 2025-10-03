import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OCRService {
  TextRecognizer? _textRecognizer;
  final imagePicker = ImagePicker();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        _isInitialized = true;
        debugPrint('ML Kit Text Recognizer initialized successfully');
      } catch (e) {
        debugPrint('Error initializing ML Kit: $e');
        _isInitialized = false;
        rethrow;
      }
    }
  }

  Future<String> recognizeText(File imageFile) async {
    try {
      if (!_isInitialized || _textRecognizer == null) {
        await initialize();
      }

      debugPrint('Processing image: ${imageFile.path}');

      // Verify file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist or is not accessible');
      }

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception(
            'Image file is too large. Please select a smaller image (under 10MB)');
      }

      // Create input image
      final inputImage = InputImage.fromFile(imageFile);
      debugPrint('Input image created successfully');

      // Process the image
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      debugPrint('Text recognition completed');

      if (recognizedText.text.isEmpty) {
        debugPrint('No text was recognized in the image');
        throw Exception('No text was recognized in the image. Please ensure:\n'
            '- The image is clear and well-lit\n'
            '- Text is clearly visible\n'
            '- Text is properly oriented\n'
            '- There is sufficient contrast between text and background');
      }

      debugPrint('Recognized text: ${recognizedText.text}');
      return recognizedText.text;
    } on PlatformException catch (e) {
      debugPrint('Platform Error in OCR: $e');
      switch (e.code) {
        case 'permission-denied':
          throw Exception(
              'Camera or storage permission denied. Please grant permissions in settings.');
        case 'invalid-image':
          throw Exception(
              'The selected image is invalid or corrupted. Please try another image.');
        case 'mlkit-error':
          // Try reinitializing ML Kit
          _isInitialized = false;
          _textRecognizer?.close();
          _textRecognizer = null;
          throw Exception('ML Kit error occurred. Please try again.');
        default:
          throw Exception('Failed to process image: ${e.message}');
      }
    } catch (e) {
      debugPrint('OCR Error: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  Future<File?> pickImage({bool fromCamera = true}) async {
    try {
      debugPrint('Requesting image from ${fromCamera ? "camera" : "gallery"}');

      final XFile? pickedFile = await imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
        preferredCameraDevice:
            fromCamera ? CameraDevice.rear : CameraDevice.front,
      );

      if (pickedFile != null) {
        debugPrint('Image picked successfully: ${pickedFile.path}');
        final file = File(pickedFile.path);

        if (await file.exists()) {
          // Verify the file is an image
          try {
            final bytes = await file.readAsBytes();
            ui.decodeImageFromList(bytes, (image) {
              // Image decoded successfully
              debugPrint(
                  'Image decoded successfully: ${image.width}x${image.height}');
            });
            return file;
          } catch (e) {
            debugPrint('Error decoding image: $e');
            throw Exception('The selected file is not a valid image');
          }
        } else {
          throw Exception(
              'Selected image file does not exist or was not saved properly');
        }
      }

      debugPrint('No image was selected');
      return null;
    } on PlatformException catch (e) {
      debugPrint('Platform Error in Image Picker: $e');
      switch (e.code) {
        case 'camera_access_denied':
          throw Exception(
              'Camera access denied. Please enable camera access in your device settings.');
        case 'photo_access_denied':
          throw Exception(
              'Photo library access denied. Please enable photo access in your device settings.');
        case 'camera_not_available':
          throw Exception('Camera is not available on this device.');
        default:
          throw Exception('Failed to pick image: ${e.message}');
      }
    } catch (e) {
      debugPrint('Image Picker Error: $e');
      throw Exception('Failed to pick image: $e');
    }
  }

  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
    _isInitialized = false;
  }
}
