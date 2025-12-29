import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart'; // FIXED: Import added

class MLOcrService {
  final TextRecognizer _textRecognizer;
  
  MLOcrService() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  Future<Map<String, dynamic>> extractAadhaarDetails(File imageFile) async {
    File? processedImage;
    try {
      print('🔍 Starting REAL OCR processing...');
      
      // Step 1: Pre-process image for better recognition
      processedImage = await _preprocessImage(imageFile);
      
      // Step 2: Create InputImage for ML Kit
      final inputImage = InputImage.fromFilePath(processedImage.path);
      
      // Step 3: Recognize text
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Step 4: Get extracted text
      String fullText = recognizedText.text;
      print('📝 ML Kit Extracted Text:\n$fullText');
      
      // Step 5: Parse Aadhaar data
      final aadhaarData = _parseAadhaarData(fullText);
      
      return aadhaarData;
      
    } catch (e, stackTrace) {
      print('❌ ML Kit Error: $e');
      print('Stack trace: $stackTrace');
      return _getEmptyDataWithError('OCR failed: $e');
    } finally {
      // Clean up temp file
      if (processedImage != null && processedImage.path != imageFile.path) {
        try {
          await processedImage.delete();
        } catch (e) {
          print('⚠️ Could not delete temp file: $e');
        }
      }
    }
  }
  
  // Image preprocessing
  Future<File> _preprocessImage(File originalImage) async {
    try {
      final bytes = await originalImage.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return originalImage;
      
      var processed = img.copyResize(image, width: 1200);
      processed = img.grayscale(processed);
      processed = img.adjustColor(processed, contrast: 100);
      processed = img.adjustColor(processed, brightness: 30);
      
      // FIXED: Use path_provider correctly
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(processed));
      
      return tempFile;
    } catch (e) {
      print('⚠️ Image preprocessing failed, using original: $e');
      return originalImage;
    }
  }
  
  Map<String, dynamic> _parseAadhaarData(String text) {
    // ... keep your existing parsing logic ...
    String cleanedText = text.toUpperCase();
    
    Map<String, dynamic> result = {
      'aadhaarNumber': '',
      'name': '',
      'dob': '',
      'gender': '',
      'address': '',
      'extractedText': cleanedText,
      'confidence': 0.0,
      'ocrMethod': 'ML Kit',
    };
    
    // ... rest of your parsing code ...
    return result;
  }
  
  Map<String, dynamic> _getEmptyDataWithError(String error) {
    return {
      'aadhaarNumber': '',
      'name': '',
      'dob': '',
      'gender': '',
      'address': '',
      'extractedText': '',
      'confidence': 0.0,
      'ocrMethod': 'ML Kit (Failed)',
      'error': error,
    };
  }
  
  // Dispose method to clean up resources
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
    } catch (e) {
      print('⚠️ Error disposing TextRecognizer: $e');
    }
  }
}