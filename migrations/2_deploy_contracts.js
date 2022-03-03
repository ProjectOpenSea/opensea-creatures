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

// If you want to hardcode what deploys, comment out process.env.X and use
// true/false;
const DEPLOY_ALL = process.env.DEPLOY_ALL;
const DEPLOY_ACCESSORIES_SALE = process.env.DEPLOY_ACCESSORIES_SALE || DEPLOY_ALL;
const DEPLOY_ACCESSORIES = process.env.DEPLOY_ACCESSORIES || DEPLOY_ACCESSORIES_SALE || DEPLOY_ALL;
const DEPLOY_CREATURES_SALE = process.env.DEPLOY_CREATURES_SALE || DEPLOY_ALL;
// Note that we will default to this unless DEPLOY_ACCESSORIES is set.
// This is to keep the historical behavior of this migration.
const DEPLOY_CREATURES = process.env.DEPLOY_CREATURES || DEPLOY_CREATURES_SALE || DEPLOY_ALL || (! DEPLOY_ACCESSORIES);

module.exports = async (deployer, network, addresses) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0x1E525EEAF261cA41b809884CBDE9DD9E1619573A";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  if (DEPLOY_CREATURES) {
    await deployer.deploy(Creature, proxyRegistryAddress, {gas: 5000000});
  }

  if (DEPLOY_CREATURES_SALE) {
    await deployer.deploy(CreatureFactory, proxyRegistryAddress, Creature.address, {gas: 7000000});
    const creature = await Creature.deployed();
    await creature.transferOwnership(CreatureFactory.address);
  }

  if (DEPLOY_ACCESSORIES) {
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
  }

  if (DEPLOY_ACCESSORIES_SALE) {
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
    const accessories = await CreatureAccessory.deployed();
    const factory = await CreatureAccessoryFactory.deployed();
    await accessories.transferOwnership(
      CreatureAccessoryFactory.address
    );
    await setupCreatureAccessories.setupAccessoryLootBox(lootBox, factory);
    await lootBox.transferOwnership(factory.address);
  }
};
