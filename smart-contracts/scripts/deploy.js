const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

async function main() {
    // Connect to local blockchain (Ganache)
    const web3 = new Web3('http://127.0.0.1:8545');
    
    // Get accounts
    const accounts = await web3.eth.getAccounts();
    console.log('Deploying from account:', accounts[0]);
    
    // Read contract ABI and bytecode
    const contractPath = path.resolve(__dirname, '../build/contracts/AadhaarVerification.json');
    const contractData = JSON.parse(fs.readFileSync(contractPath, 'utf8'));
    
    // Create contract instance
    const contract = new web3.eth.Contract(contractData.abi);
    
    // Deploy contract
    const deployTx = contract.deploy({
        data: contractData.bytecode,
        arguments: []
    });
    
    const gas = await deployTx.estimateGas();
    const gasPrice = await web3.eth.getGasPrice();
    
    console.log('Estimated gas:', gas);
    console.log('Gas price:', gasPrice);
    
    // Send deployment transaction
    const deployedContract = await deployTx.send({
        from: accounts[0],
        gas: gas,
        gasPrice: gasPrice
    });
    
    console.log('✅ Contract deployed at:', deployedContract.options.address);
    
    // Save contract address and ABI for Flutter app
    const output = {
        address: deployedContract.options.address,
        abi: contractData.abi
    };
    
    // Save to Flutter assets folder
    const flutterAssetsPath = path.resolve(__dirname, '../../flutter-app/assets');
    
    // Ensure directory exists
    if (!fs.existsSync(flutterAssetsPath)) {
        fs.mkdirSync(flutterAssetsPath, { recursive: true });
    }
    
    // Save contract info
    fs.writeFileSync(
        path.join(flutterAssetsPath, 'contract_abi.json'),
        JSON.stringify(contractData.abi, null, 2)
    );
    
    fs.writeFileSync(
        path.join(flutterAssetsPath, 'contract_address.txt'),
        deployedContract.options.address
    );
    
    console.log('📁 Contract info saved to Flutter assets folder');
    
    // Test the contract
    console.log('\n🧪 Testing contract...');
    
    // Set owner
    await deployedContract.methods.registerAadhaar(
        "test_hash_123",
        "Test User",
        "01/01/1990",
        "Male",
        "address_hash_456",
        "encrypted_data_789"
    ).send({ from: accounts[0] });
    
    const count = await deployedContract.methods.getRecordCount().call();
    console.log('Total records:', count);
    
    const isRegistered = await deployedContract.methods
        .isAadhaarRegistered("test_hash_123")
        .call();
    console.log('Is registered?', isRegistered);
}

main().catch(console.error);