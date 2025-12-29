const AadhaarVerification = artifacts.require("AadhaarVerification");

contract("AadhaarVerification", (accounts) => {
    let contract;
    const owner = accounts[0];
    const testHash = "test_aadhaar_hash_123";
    const testName = "John Doe";
    const testDob = "15/08/1990";
    const testGender = "Male";
    const testAddressHash = "address_hash_xyz";
    const testEncrypted = "encrypted_data_abc";

    beforeEach(async () => {
        contract = await AadhaarVerification.new({ from: owner });
    });

    it("should deploy contract successfully", async () => {
        assert.ok(contract.address);
    });

    it("should register Aadhaar data", async () => {
        await contract.registerAadhaar(
            testHash,
            testName,
            testDob,
            testGender,
            testAddressHash,
            testEncrypted,
            { from: owner }
        );

        const result = await contract.verifyAadhaar(testHash);
        assert.equal(result.name, testName);
        assert.equal(result.dob, testDob);
        assert.equal(result.gender, testGender);
        assert.equal(result.isVerified, true);
    });

    it("should not allow duplicate registration", async () => {
        await contract.registerAadhaar(
            testHash,
            testName,
            testDob,
            testGender,
            testAddressHash,
            testEncrypted,
            { from: owner }
        );

        try {
            await contract.registerAadhaar(
                testHash,
                "Another Name",
                testDob,
                testGender,
                testAddressHash,
                testEncrypted,
                { from: owner }
            );
            assert.fail("Should have thrown error");
        } catch (error) {
            assert.include(error.message, "Aadhaar already registered");
        }
    });

    it("should increment record count", async () => {
        const initialCount = await contract.getRecordCount();
        assert.equal(initialCount, 0);

        await contract.registerAadhaar(
            testHash,
            testName,
            testDob,
            testGender,
            testAddressHash,
            testEncrypted,
            { from: owner }
        );

        const finalCount = await contract.getRecordCount();
        assert.equal(finalCount, 1);
    });
});