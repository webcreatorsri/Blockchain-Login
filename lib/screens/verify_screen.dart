import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';

class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final BlockchainService _blockchainService = BlockchainService();
  Map<String, dynamic>? _verificationResult;
  bool _isVerifying = false;

  Future<void> _verifyAadhaar() async {
    if (_aadhaarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter Aadhaar number')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      final result = await _blockchainService.verifyAadhaar(
        _aadhaarController.text,
      );
      
      setState(() {
        _verificationResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Aadhaar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('🔍 Verify Aadhaar on Blockchain',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _aadhaarController,
                      decoration: InputDecoration(
                        labelText: 'Enter Aadhaar Number/Encrypted Hash',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isVerifying
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _verifyAadhaar,
                            icon: Icon(Icons.verified),
                            label: Text('VERIFY ON BLOCKCHAIN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            
            if (_verificationResult != null) ...[
              SizedBox(height: 20),
              Card(
                color: _verificationResult!['isVerified']
                    ? Colors.green[50]
                    : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _verificationResult!['isVerified']
                                ? Icons.verified
                                : Icons.warning,
                            color: _verificationResult!['isVerified']
                                ? Colors.green
                                : Colors.red,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _verificationResult!['isVerified']
                                ? '✅ VERIFIED'
                                : '❌ NOT VERIFIED',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _verificationResult!['isVerified']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _verificationInfo('Name', _verificationResult!['name']),
                      _verificationInfo('Date of Birth', _verificationResult!['dob']),
                      _verificationInfo('Gender', _verificationResult!['gender']),
                      _verificationInfo('Timestamp',
                          DateTime.fromMillisecondsSinceEpoch(
                                  _verificationResult!['timestamp'])
                              .toString()),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            Text(
              'Note: This verifies the Aadhaar data stored on the blockchain network.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _verificationInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}