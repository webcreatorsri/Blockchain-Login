// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AadhaarVerification {
    struct AadhaarData {
        string aadhaarHash;
        string name;
        string dob;
        string gender;
        string addressHash;
        uint256 timestamp;
        bool isVerified;
        string encryptedData; // Encrypted Aadhaar details
    }
    
    mapping(string => AadhaarData) private aadhaarRecords;
    address public owner;
    uint256 public recordCount;
    
    event AadhaarRegistered(string indexed aadhaarHash, uint256 timestamp);
    event AadhaarVerified(string indexed aadhaarHash, bool status);
    
    constructor() {
        owner = msg.sender;
        recordCount = 0;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // Store Aadhaar data on blockchain
    function registerAadhaar(
        string memory _aadhaarHash,
        string memory _name,
        string memory _dob,
        string memory _gender,
        string memory _addressHash,
        string memory _encryptedData
    ) public onlyOwner {
        require(bytes(aadhaarRecords[_aadhaarHash].aadhaarHash).length == 0, 
                "Aadhaar already registered");
        
        aadhaarRecords[_aadhaarHash] = AadhaarData({
            aadhaarHash: _aadhaarHash,
            name: _name,
            dob: _dob,
            gender: _gender,
            addressHash: _addressHash,
            timestamp: block.timestamp,
            isVerified: true,
            encryptedData: _encryptedData
        });
        
        recordCount++;
        emit AadhaarRegistered(_aadhaarHash, block.timestamp);
    }
    
    // Verify Aadhaar from blockchain
    function verifyAadhaar(string memory _aadhaarHash) public view returns (
        string memory name,
        string memory dob,
        string memory gender,
        bool isVerified,
        uint256 timestamp,
        string memory encryptedData
    ) {
        AadhaarData memory data = aadhaarRecords[_aadhaarHash];
        require(bytes(data.aadhaarHash).length > 0, "Aadhaar not found");
        
        return (
            data.name,
            data.dob,
            data.gender,
            data.isVerified,
            data.timestamp,
            data.encryptedData
        );
    }
    
    // Get total number of records
    function getRecordCount() public view returns (uint256) {
        return recordCount;
    }
    
    // Check if Aadhaar exists
    function isAadhaarRegistered(string memory _aadhaarHash) public view returns (bool) {
        return bytes(aadhaarRecords[_aadhaarHash].aadhaarHash).length > 0;
    }
}