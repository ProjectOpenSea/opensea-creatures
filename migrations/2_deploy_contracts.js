const MyItem = artifacts.require("./MyItem.sol");

module.exports = function(deployer) {
  deployer.deploy(MyItem, "Cryptofluffies", "FLUFF");
};