const OpenSeaCreature = artifacts.require("./OpenSeaCreature.sol");
const OpenSeaCreatureFactory = artifacts.require("./OpenSeaCreatureFactory.sol")
const OpenSeaCreatureLootBox = artifacts.require("./OpenSeaCreatureLootBox.sol");

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = ""
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }
  deployer.deploy(OpenSeaCreature, proxyRegistryAddress, {gas: 5000000}).then(() => {
    return deployer.deploy(OpenSeaCreatureFactory, proxyRegistryAddress, OpenSeaCreature.address, {gas: 7000000});
  }).then(async() => {
    var openSeaCreature = await OpenSeaCreature.deployed();
    return openSeaCreature.transferOwnership(OpenSeaCreatureFactory.address);
  })
};