const Creature = artifacts.require("./Creature.sol");
const CreatureFactory = artifacts.require("./CreatureFactory.sol");
const CreatureLootBox = artifacts.require("./CreatureLootBox.sol");
const CreatureAccessory = artifacts.require("CreatureAccessory");
const CreatureAccessoryLootBox = artifacts.require("CreatureAccessoryLootBox");
const LootBoxRandomness = artifacts.require("LootBoxRandomness");

// Set to false if you only want the collectible to deploy
const ACCESSORIES_ENABLE_LOOTBOX = true;
// Set if you want to create your own collectible
const ACCESSORIES_NFT_ADDRESS_TO_USE = CreatureAccessory.address; // or e.g. Enjin: '0xfaafdc07907ff5120a76b34b731b278c38d6043c'
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

  deployer.deploy(CreatureAccessory, proxyRegistryAddress, { gas: 5000000 })
  .then(async() => {
    return deployer.deploy(
      LootBoxRandomness
    ).then(async () => {
      return deployer.link(LootBoxRandomness, CreatureAccessoryLootBox);
    }).then(async () => {
      const collectible = await CreatureAccessory.deployed();
      return deployer.deploy(
        CreatureAccessoryLootBox,
        proxyRegistryAddress,
        { gas: 6721975 });
    }).then(setupAccessoriesLootbox);
  });
};

async function setupAccessoriesLootbox() {
  const lootbox = await CreatureAccessoryLootBox.deployed();
  const collectible = await CreatureAccessory.deployed();

  if (!ACCESSORIES_NFT_ADDRESS_TO_USE) {
    await collectible.transferOwnership(CreatureAccessoryLootBox.address);
  }

  await lootbox.setState(
    ACCESSORIES_NFT_ADDRESS_TO_USE || collectible.address,
    3,
    6,
    1337
  );

  if (ACCESSORIES_TOKEN_ID_MAPPING) {
    for (const rarity in ACCESSORIES_TOKEN_ID_MAPPING) {
      console.log(`Setting token ids for rarity ${rarity}`);
      const tokenIds = ACCESSORIES_TOKEN_ID_MAPPING[rarity];
      await lootbox.setTokenIdsForClass(rarity, tokenIds);
    }
  }
}
