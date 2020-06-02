const Creature = artifacts.require("./Creature.sol");
const CreatureFactory = artifacts.require("./CreatureFactory.sol");
const CreatureLootBox = artifacts.require("./CreatureLootBox.sol");
const CreatureAccessory = artifacts.require("../contracts/CreatureAccessory.sol");
const CreatureAccessoryFactory = artifacts.require("../contracts/CreatureAccessoryFactory.sol");
const CreatureAccessoryLootBox = artifacts.require(
  "../contracts/CreatureAccessoryLootBox.sol"
);
const LootBoxRandomness = artifacts.require(
  "../contracts/LootBoxRandomness.sol"
);

const setupCreatureAccessories = require("../lib/setupCreatureAccessories.js");

// Set to false if you only want the collectible to deploy
const ACCESSORIES_ENABLE_LOOTBOX = true;
// Set if you want to create your own collectible
const ACCESSORIES_NFT_ADDRESS_TO_USE = null; // or e.g. Enjin: '0xfaafdc07907ff5120a76b34b731b278c38d6043c'

module.exports = async (deployer, network, addresses) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  await deployer.deploy(Creature, proxyRegistryAddress, {gas: 5000000});

  // Uncomment this if you want initial item sale support.
  // await deployer.deploy(Creature, proxyRegistryAddress, {gas: 5000000});
  // await deployer.deploy(CreatureFactory, proxyRegistryAddress, Creature.address, {gas: 7000000});
  // const creature = await Creature.deployed();
  // await creature.transferOwnership(CreatureFactory.address);

  // Comment this out if you don't want to deploy the accessories
  await deployer.deploy(
    CreatureAccessory,
    proxyRegistryAddress,
    { gas: 5000000 }
  );
  const accessories = await CreatureAccessory.deployed();
  await setupCreatureAccessories.setupAccessory(
    accessories,
    addresses[0]
  );
  // Uncomment this if you want initial accessory sale support.
  // (Or you want to run the tests.)
  /*
  await deployer.deploy(LootBoxRandomness);
  await deployer.link(LootBoxRandomness, CreatureAccessoryLootBox);
  await deployer.deploy(
    CreatureAccessoryLootBox,
    proxyRegistryAddress,
    { gas: 6721975 }
  );
  const lootBox = await CreatureAccessoryLootBox.deployed();
  await deployer.deploy(
    CreatureAccessoryFactory,
    proxyRegistryAddress,
    CreatureAccessory.address,
    CreatureAccessoryLootBox.address,
    { gas: 5000000 }
  );
  const factory = await CreatureAccessoryFactory.deployed();
  await accessories.setApprovalForAll(
    addresses[0],
    CreatureAccessoryFactory.address
  );
  await accessories.transferOwnership(
    CreatureAccessoryFactory.address
  );
  await setupCreatureAccessories.setupAccessoryLootBox(lootBox, factory);
  await lootBox.transferOwnership(factory.address);
  */
};
