const CryptoPenguin = artifacts.require("./CryptoPenguin.sol");

module.exports = function(deployer) {
  deployer.deploy(CryptoPenguin);
};