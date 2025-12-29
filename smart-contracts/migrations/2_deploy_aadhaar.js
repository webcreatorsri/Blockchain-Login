const AadhaarVerification = artifacts.require("AadhaarVerification");

module.exports = function(deployer) {
  deployer.deploy(AadhaarVerification);
};