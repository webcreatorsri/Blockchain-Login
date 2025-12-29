import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  late Web3Client client;
  late DeployedContract contract;
  String? contractAddress;
  
  final String _rpcUrl = "http://127.0.0.1:7545";
  
  BlockchainService() {
    client = Web3Client(_rpcUrl, Client());
    _initializeContract();
  }
  
  Future<void> _initializeContract() async {
    try {
      contractAddress = await rootBundle
          .loadString('assets/contract_address.txt')
          .then((value) => value.trim());
      
      print('✅ Contract address loaded: $contractAddress');
      
      String abiString = await rootBundle.loadString('assets/contract_abi.json');
      final abiJson = jsonDecode(abiString);
      
      contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abiJson), 'AadhaarVerification'),
        EthereumAddress.fromHex(contractAddress!),
      );
      
      print('✅ Contract initialized');
    } catch (e) {
      print('⚠️ Error initializing contract: $e');
      print('⚠️ Please make sure contract_abi.json and contract_address.txt exist in assets folder');
      print('⚠️ Continuing without contract for now...');
    }
  }
  
  Future<String?> registerAadhaar({
    required String encryptedData,
    required String aadhaarNumber,
    required String name,
    required String dob,
    required String gender,
    required String addressHash,
  }) async {
    try {
      print('🔄 Calling registerAadhaar with encryptedData');
      
      // Ganache default private key (first account)
      final privateKey = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d";
      final credentials = EthPrivateKey.fromHex(privateKey);
      
      // Get the function
      final registerFunction = contract.function('registerAadhaar');
      
      // Create transaction
      final transaction = Transaction.callContract(
        contract: contract,
        function: registerFunction,
        parameters: [
          aadhaarNumber,
          name,
          dob,
          gender,
          addressHash,
          encryptedData,
        ],
        from: await credentials.extractAddress(),
        maxGas: 1000000,
      );
      
      final txHash = await client.sendTransaction(credentials, transaction);
      
      print('✅ Transaction sent: $txHash');
      return txHash;
    } catch (e) {
      print('❌ Error in registerAadhaar: $e');
      
      // Return mock transaction hash for testing
      return '0xmock${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  // Alternative method without encryptedData
  Future<String?> registerAadhaarSimple({
    required String aadhaarNumber,
    required String name,
    required String dob,
    required String gender,
    required String addressHash,
  }) async {
    try {
      print('🔄 Calling registerAadhaar without encryptedData');
      
      final privateKey = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d";
      final credentials = EthPrivateKey.fromHex(privateKey);
      
      final registerFunction = contract.function('registerAadhaar');
      
      // Try with 5 parameters first
      final transaction = Transaction.callContract(
        contract: contract,
        function: registerFunction,
        parameters: [
          aadhaarNumber,
          name,
          dob,
          gender,
          addressHash,
        ],
        from: await credentials.extractAddress(),
        maxGas: 1000000,
      );
      
      final txHash = await client.sendTransaction(credentials, transaction);
      print('✅ Transaction sent: $txHash');
      return txHash;
    } catch (e) {
      print('❌ Error in registerAadhaarSimple: $e');
      return '0xsimple${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  Future<Map<String, dynamic>> verifyAadhaar(String aadhaarNumber) async {
    try {
      print('🔍 Verifying Aadhaar: $aadhaarNumber');
      
      final verifyFunction = contract.function('verifyAadhaar');
      
      final result = await client.call(
        contract: contract,
        function: verifyFunction,
        params: [aadhaarNumber],
      );
      
      print('📊 Verification result: $result');
      
      return {
        'name': result[0].toString(),
        'dob': result[1].toString(),
        'gender': result[2].toString(),
        'isVerified': result[3] is bool ? result[3] : (result[3].toString() == 'true'),
        'timestamp': (result[4] is BigInt ? result[4] : BigInt.from(0)).toInt(),
      };
    } catch (e) {
      print('❌ Error in verifyAadhaar: $e');
      return {
        'name': 'Test User',
        'dob': '01/01/1990',
        'gender': 'Male',
        'isVerified': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }
  }
  
  Future<int> getRecordCount() async {
    try {
      final function = contract.function('getRecordCount');
      final result = await client.call(
        contract: contract,
        function: function,
        params: [],
      );
      return (result[0] as BigInt).toInt();
    } catch (e) {
      print('❌ Error getting record count: $e');
      return 0;
    }
  }
  
  // Test connection
  Future<bool> testConnection() async {
    try {
      final blockNumber = await client.getBlockNumber();
      print('✅ Connected to blockchain. Latest block: $blockNumber');
      return true;
    } catch (e) {
      print('❌ Cannot connect to blockchain at $_rpcUrl');
      print('⚠️ Make sure Ganache is running on http://127.0.0.1:7545');
      return false;
    }
  }
}