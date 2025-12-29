import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'aadhaar_upload_screen.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👋 Welcome,',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 5),
                    Text(user?.email ?? 'User',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    Text('Aadhaar Blockchain Verification System',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Main Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AadhaarUploadScreen()),
                  );
                },
                icon: Icon(Icons.cloud_upload, size: 30),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'UPLOAD AADHAAR CARD',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Features List
            Expanded(
              child: ListView(
                children: [
                  _featureTile(
                    icon: Icons.block,
                    title: 'Blockchain Security',
                    subtitle: 'Data stored on immutable blockchain',
                  ),
                  _featureTile(
                    icon: Icons.verified,
                    title: 'Verification',
                    subtitle: 'Verify Aadhaar authenticity',
                  ),
                  _featureTile(
                    icon: Icons.security,
                    title: 'Encryption',
                    subtitle: 'End-to-end encryption',
                  ),
                  _featureTile(
                    icon: Icons.cloud,
                    title: 'Cloud Storage',
                    subtitle: 'Secure Firebase storage',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}