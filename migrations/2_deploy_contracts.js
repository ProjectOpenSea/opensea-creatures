const CryptoPuff = artifacts.require("./CryptoPuff.sol");
const CryptoPuffFactory = artifacts.require("./CryptoPuffFactory.sol")
const CryptoPuffLootBox = artifacts.require("./CryptoPuffLootBox.sol");

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = ""
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }
  deployer.deploy(CryptoPuff, proxyRegistryAddress, {gas: 5000000}).then(() => {
    return deployer.deploy(CryptoPuffFactory, proxyRegistryAddress, CryptoPuff.address, {gas: 7000000});
  }).then(async() => {
    var cryptoPuff = await CryptoPuff.deployed();
    return cryptoPuff.transferOwnership(CryptoPuffFactory.address);
  })
};