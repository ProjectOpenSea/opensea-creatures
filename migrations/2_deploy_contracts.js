const CryptoPuff = artifacts.require("./CryptoPuff.sol");

module.exports = function(deployer) {
  deployer.deploy(CryptoPuff);
};