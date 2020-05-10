/* Contracts in this test */

const CreatureAccessory = artifacts.require(
  "../contracts/CreatureAccessory.sol"
);


contract("CreatureAccessory", (accounts) => {
  const URI_BASE = 'https://creatures-api.opensea.io';
  const CONTRACT_URI = `${URI_BASE}/contract/opensea-erc1155`;
  let creatureAccessory;

  before(async () => {
    creatureAccessory = await CreatureAccessory.deployed();
  });

  // This is all we test for now

  // This also tests contractURI()

  describe('#constructor()', () => {
    it('should set the contractURI to the supplied value', async () => {
      assert.equal(await creatureAccessory.contractURI(), CONTRACT_URI);
    });
  });
});
