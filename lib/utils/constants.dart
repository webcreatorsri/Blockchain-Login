class AppConstants {
  // Colors
  static const primaryColor = Color(0xFF2196F3);
  static const secondaryColor = Color(0xFF4CAF50);
  static const accentColor = Color(0xFF9C27B0);
  
  // Strings
  static const appName = 'Aadhaar Blockchain';
  static const appSlogan = 'Secure Aadhaar Verification';
  
  // Firebase Collection Names
  static const usersCollection = 'users';
  static const aadhaarCollection = 'aadhaar_records';
  static const transactionsCollection = 'blockchain_transactions';
  
  // Blockchain
  static const rpcUrl = 'http://127.0.0.1:7545';
  
  // Status Messages
  static const success = 'Success';
  static const error = 'Error';
  static const loading = 'Loading...';
  
  // Validation Messages
  static const enterEmail = 'Please enter email';
  static const enterPassword = 'Please enter password';
  static const passwordTooShort = 'Password must be at least 6 characters';
  static const passwordsDontMatch = 'Passwords do not match';
}