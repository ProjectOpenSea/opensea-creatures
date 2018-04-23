const Migrations = artifacts.require("../node_modules/zeppelin-solidity/contracts/lifecycle/Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};