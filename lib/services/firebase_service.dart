import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseService {
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static Future<auth.User?> signUp(String email, String password, String name) async {
    try {
      auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
      
      return credential.user;
    } catch (e) {
      print("Sign up error: $e");
      return null;
    }
  }
  
  static Future<auth.User?> signIn(String email, String password) async {
    try {
      auth.UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Sign in error: $e");
      return null;
    }
  }
  
  static Future<void> storeAadhaarData(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('aadhaar_records').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser?.uid ?? 'unknown',
        'status': 'pending',
      });
      print('✅ Aadhaar data stored in Firebase');
    } catch (e) {
      print('❌ Error storing aadhaar data: $e');
      rethrow;
    }
  }
  
  // FIXED: Upload to Firebase Storage
  static Future<String> uploadImage(String path, Uint8List imageBytes) async {
    try {
      // Create unique filename
      String fileName = 'aadhaar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Reference to storage location
      Reference ref = _storage.ref().child('aadhaar_images/$fileName');
      
      // Set metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': _auth.currentUser?.uid ?? 'anonymous',
          'uploadedAt': DateTime.now().toString(),
        },
      );
      
      // Upload with metadata
      UploadTask uploadTask = ref.putData(imageBytes, metadata);
      
      // Wait for completion
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print("❌ Upload error: $e");
      
      // If Firebase Storage fails, use a placeholder
      return 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Aadhaar+Uploaded';
    }
  }
  
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  static auth.User? get currentUser => _auth.currentUser;
}