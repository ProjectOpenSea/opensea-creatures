const CryptoPuff = artifacts.require("./CryptoPuff.sol");

module.exports = function(deployer, network) {
  console.log(network);

  // OpenSea proxy registry addresses for rinkeby and mainnet.
  if (network == 'rinkeby') {
    let proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    let proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }
  deployer.deploy(CryptoPuff, proxyRegistryAddress, {gas: 5000000});
};