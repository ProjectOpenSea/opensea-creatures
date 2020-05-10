const Creature = artifacts.require("./Creature.sol");
const CreatureFactory = artifacts.require("./CreatureFactory.sol");
const CreatureLootBox = artifacts.require("./CreatureLootBox.sol");
const CreatureAccessory = artifacts.require("CreatureAccessory");
const CreatureAccessoryLootBox = artifacts.require("CreatureAccessoryLootBox");

// Set to false if you only want the collectible to deploy
const ACCESSORIES_ENABLE_LOOTBOX = true;
// Set if you want to create your own collectible
const ACCESSORIES_NFT_ADDRESS_TO_USE = undefined; // e.g. Enjin: '0xfaafdc07907ff5120a76b34b731b278c38d6043c'
// If you want to set preminted token ids for specific classes
const ACCESSORIES_TOKEN_ID_MAPPING = undefined; // { [key: number]: Array<[tokenId: string]> }

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  deployer.deploy(Creature, proxyRegistryAddress, {gas: 5000000});
  
  // Uncomment this if you want initial item sale support.
  // deployer.deploy(Creature, proxyRegistryAddress, {gas: 5000000}).then(() => {
  //   return deployer.deploy(CreatureFactory, proxyRegistryAddress, Creature.address, {gas: 7000000});
  // }).then(async() => {
  //   var creature = await Creature.deployed();
  //   return creature.transferOwnership(CreatureFactory.address);
  // })

  if (!ACCESSORIES_ENABLE_LOOTBOX) {
    deployer.deploy(CreatureAccessory, proxyRegistryAddress, { gas: 5000000 });
  } else if (ACCESSORIES_NFT_ADDRESS_TO_USE) {
    deployer.deploy(
      CreatureAccessoryLootBox,
      proxyRegistryAddress,
      ACCESSORIES_NFT_ADDRESS_TO_USE,
      { gas: 5000000 }
    ).then(setupAccessoriesLootbox);
  } else {
    deployer.deploy(CreatureAccessory, proxyRegistryAddress, {gas: 5000000})
      .then(() => {
        return deployer.deploy(
          CreatureAccessoryLootBox,
          proxyRegistryAddress,
          CreatureAccessory.address,
          { gas: 5000000 }
        );
      }).then(setupAccessoriesLootbox);
  }
};

async function setupAccessoriesLootbox() {
  if (!ACCESSORIES_NFT_ADDRESS_TO_USE) {
    const collectible = await CreatureAccessory.deployed();
    await collectible.transferOwnership(CreatureAccessoryLootBox.address);
  }

  if (ACCESSORIES_TOKEN_ID_MAPPING) {
    const lootbox = await CreatureAccessoryLootBox.deployed();
    for (const rarity in ACCESSORIES_TOKEN_ID_MAPPING) {
      console.log(`Setting token ids for rarity ${rarity}`);
      const tokenIds = ACCESSORIES_TOKEN_ID_MAPPING[rarity];
      await lootbox.setTokenIdsForClass(rarity, tokenIds);
    }
  }
}
