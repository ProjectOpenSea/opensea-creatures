/* libraries used */

const truffleAssert = require('truffle-assertions');

const vals = require('../lib/testValuesCommon.js');


/* Contracts in this test */

const MockProxyRegistry = artifacts.require(
  "../contracts/MockProxyRegistry.sol"
);
const CreatureAccessory = artifacts.require("../contracts/CreatureAccessory.sol");
const CreatureAccessoryFactory = artifacts.require("../contracts/CreatureAccessoryFactory.sol");
const CreatureAccessoryLootBox = artifacts.require("../contracts/CreatureAccessoryLootBox.sol");
const LootBoxRandomness = artifacts.require(
  "../contracts/LootBoxRandomness.sol"
);
const TestForReentrancyAttack = artifacts.require(
  "../contracts/TestForReentrancyAttack.sol"
);


/* Useful aliases */

const toBN = web3.utils.toBN;


/* Utilities */

const toTokenId = optionId => optionId + 1;


contract("CreatureAccessoryFactory", (accounts) => {
  // As set in (or inferred from) the contracts
  const NUM_CLASSES = 6;
  const BASIC = 0;
  const PREMIUM = 1;
  const GOLD = 2;
  const NUM_OPTIONS = 3;
  const NO_SUCH_OPTION = NUM_OPTIONS + 10;
  
  const owner = accounts[0];
  const userA = accounts[1];
  const userB = accounts[2];
  const proxyForOwner = accounts[8];

  let creatureAccessory;
  let myFactory;
  let myLootBox;
  let attacker;
  let proxy;

  // To install the proxy mock and the attack contract we deploy our own
  // instances of all the classes here rather than using the ones that Truffle
  // deployed.

  before(async () => {
    proxy = await MockProxyRegistry.new();
    await proxy.setProxy(owner, proxyForOwner);
    creatureAccessory = await CreatureAccessory.new(proxy.address);
    CreatureAccessoryLootBox.link(LootBoxRandomness);
    myLootBox = await CreatureAccessoryLootBox.new(proxy.address);
    myFactory = await CreatureAccessoryFactory.new(
      proxy.address,
      myLootBox.address);
    await creatureAccessory.transferOwnership(myLootBox.address);
    // Manually configure this state as we have manually deployed.
    await myLootBox.setState(
      creatureAccessory.address,
      NUM_OPTIONS,
      NUM_CLASSES,
      1337
    );
    await myLootBox.setOptionSettings(
      BASIC,
      3,
      [7300, 2100, 400, 100, 50, 50],
      [0, 0, 0, 0, 0, 0]
    );
    await myLootBox.setOptionSettings(
      PREMIUM,
      5,
      [7300, 2100, 400, 100, 50, 50],
      [3, 0, 0, 0, 0, 0]
    );
    await myLootBox.setOptionSettings(
      GOLD,
      7,
      [7300, 2100, 400, 100, 50, 50],
      [3, 0, 2, 0, 1, 0]
    );
    await myLootBox.transferOwnership(myFactory.address);
    attacker = await TestForReentrancyAttack.new();
    await attacker.setFactoryAddress(myFactory.address);
  });

  // This also tests the proxyRegistryAddress and lootBoxAddress accessors.

  describe('#constructor()', () => {
    it('should set proxyRegistryAddress to the supplied value', async () => {
      assert.equal(await myFactory.proxyRegistryAddress(), proxy.address);
      assert.equal(await myFactory.lootBoxAddress(), myLootBox.address);
    });
  });

  describe('#name()', () => {
    it('should return the correct name', async () => {
      assert.equal(
        await myFactory.name(),
        'OpenSea Creature Accessory Pre-Sale'
      );
    });
  });

  describe('#symbol()', () => {
    it('should return the correct symbol', async () => {
      assert.equal(await myFactory.symbol(), 'OSCAP');
    });
  });

  describe('#supportsFactoryInterface()', () => {
    it('should return true', async () => {
      assert.isOk(await myFactory.supportsFactoryInterface());
    });
  });

  describe('#factorySchemaName()', () => {
    it('should return the schema name', async () => {
      assert.equal(await myFactory.factorySchemaName(), 'ERC1155');
    });
  });

  describe('#numOptions()', () => {
    it('should return the correct number of options', async () => {
      assert.equal(await myFactory.numOptions(), NUM_OPTIONS);
    });
  });

  //NOTE: We test this early relative to its place in the source code as we
  //      mint tokens that we rely on the existence of in later tests here.
  
  describe('#mint()', () => {
    it('should not allow non-owner or non-operator to mint', async () => {
      await truffleAssert.fails(
        myFactory.mint(PREMIUM, userA, 1000, "0x0", { from: userA }),
        truffleAssert.ErrorType.revert,
        'CreatureAccessoryFactory#_mint: CANNOT_MINT_MORE'
      );
    });

    it('should allow owner to mint', async () => {
      const quantity = toBN(1000);
      await myFactory.mint(PREMIUM, userA, quantity, "0x0", { from: owner });
      // Check that the recipient got the correct quantity
      // Token numbers are one higher than option numbers
      const balanceUserA = await myLootBox.balanceOf(userA, toTokenId(PREMIUM));
      assert.isOk(balanceUserA.eq(quantity));
      // Check that balance is correct
      const balanceOf = await myFactory.balanceOf(owner, PREMIUM);
      assert.isOk(balanceOf.eq(vals.MAX_UINT256_BN.sub(quantity)));
      // Check that total supply is correct
      const totalSupply = await myLootBox.totalSupply(toTokenId(PREMIUM));
      assert.isOk(totalSupply.eq(quantity));
    });

    it('should allow proxy to mint', async () => {
      const quantity = toBN(100);
      //FIXME: move all quantities to top level constants
      const total = toBN(1100);
      await myFactory.mint(
        PREMIUM,
        userA,
        quantity,
        "0x0",
        { from: proxyForOwner }
      );
      // Check that the recipient got the correct quantity
      const balanceUserA = await myLootBox.balanceOf(userA, toTokenId(PREMIUM));
      assert.isOk(balanceUserA.eq(total));
      // Check that balance is correct
      const balanceOf = await myFactory.balanceOf(owner, PREMIUM);
      assert.isOk(balanceOf.eq(vals.MAX_UINT256_BN.sub(total)));
      // Check that total supply is correct
      const totalSupply = await myLootBox.totalSupply(toTokenId(PREMIUM));
      assert.isOk(totalSupply.eq(total));
    });
  });

  describe('#canMint()', () => {
    it('should return false for zero _amount', async () => {
      assert.isNotOk(await myFactory.canMint(BASIC, 0, { from: userA }));
      assert.isNotOk(await myFactory.canMint(BASIC, 0, { from: owner }));
      assert.isNotOk(
        await myFactory.canMint(BASIC, 0, { from: proxyForOwner })
      );
    });

    it('should return false for non-owner and non-proxy', async () => {
      assert.isNotOk(await myFactory.canMint(BASIC, 100, { from: userA }));
    });

    it('should return true for un-minted token', async () => {
      assert.isOk(await myFactory.canMint(BASIC, 1, { from: owner }));
      //FIXME: Why 'invalid opcode'?
      //assert.isOk(await myFactory.canMint(GOLD, MAX_UINT256_BN, { from: owner }));
      assert.isOk(await myFactory.canMint(BASIC, 1, { from: proxyForOwner }));
    });

    it('should return true for minted token for available amount', async () => {
      assert.isOk(await myFactory.canMint(PREMIUM, 1, { from: owner }));
      assert.isOk(await myFactory.canMint(PREMIUM, 1, { from: proxyForOwner }));
    });
  });

  describe('#uri()', () => {
    it('should return the correct uri for an option', async () =>
      assert.equal(await myFactory.uri(BASIC), `${vals.URI_BASE}factory/0`)
      );

    it('should format any number as an option uri', async () =>
       assert.equal(
         await myFactory.uri(vals.MAX_UINT256),
         `${vals.URI_BASE}factory/${toBN(vals.MAX_UINT256).toString()}`
       ));
  });

  describe('#balanceOf()', () => {
    it('should return max supply for un-minted token', async () => {
      const balanceOwner = await myFactory.balanceOf(owner, BASIC);
      assert.isOk(balanceOwner.eq(vals.MAX_UINT256_BN));
      const balanceProxy = await myFactory.balanceOf(
        proxyForOwner,
        NO_SUCH_OPTION
      );
      assert.isOk(balanceProxy.eq(vals.MAX_UINT256_BN));
    });

    it('should return balance of minted token', async () => {
      const balance = vals.MAX_UINT256_BN.sub(toBN(1100));
      const balanceOwner = await myFactory.balanceOf(owner, PREMIUM);
      assert.isOk(balanceOwner.eq(balance));
      const balanceProxy = await myFactory.balanceOf(proxyForOwner, PREMIUM);
      assert.isOk(balanceProxy.eq(balance));
    });

    it('should return zero for non-owner or non-proxy', async () => {
      assert.isOk((await myFactory.balanceOf(userA, BASIC)).eq(toBN(0)));
      assert.isOk((await myFactory.balanceOf(userB, GOLD)).eq(toBN(0)));
    });
  });

  //NOTE: we should test safeTransferFrom with both an existing and not-yet-
  //      created token to exercise both paths in its calls of _create().
  //      But we test _create() in create() and we don't reset the contracts
  //      between describe() calls so we only test one path here, and let
  //      the other be tested in create().

  describe('#safeTransferFrom()', () => {
    it('should work for owner()', async () => {
      const amount = toBN(100);
      const userBBalance = await myLootBox.balanceOf(userB, toTokenId(PREMIUM));
      await myFactory.safeTransferFrom(
        vals.ADDRESS_ZERO,
        userB,
        PREMIUM,
        amount,
        "0x0"
      );
      const newUserBBalance = await myLootBox.balanceOf(userB, toTokenId(PREMIUM));
      assert.isOk(newUserBBalance.eq(userBBalance.add(amount)));
    });

    it('should work for proxy', async () => {
      const amount = toBN(100);
      const userBBalance = await myLootBox.balanceOf(userB, toTokenId(PREMIUM));
      await myFactory.safeTransferFrom(
        vals.ADDRESS_ZERO,
        userB,
        PREMIUM,
        100,
        "0x0",
        { from: proxyForOwner }
      );
      const newUserBBalance = await myLootBox.balanceOf(userB, toTokenId(PREMIUM));
      assert.isOk(newUserBBalance.eq(userBBalance.add(amount)));
    });

    it('should not be callable by non-owner() and non-proxy', async () => {
      const amount = toBN(100);
      await truffleAssert.fails(
        myFactory.safeTransferFrom(
          vals.ADDRESS_ZERO,
          userB,
          PREMIUM,
          amount,
          "0x0",
          { from: userB }
        ),
        truffleAssert.ErrorType.revert,
        'CreatureAccessoryFactory#_mint: CANNOT_MINT_MORE'
      );
    });
  });

  describe('#isApprovedForAll()', () => {
    it('should approve owner as both _owner and _operator', async () => {
      assert.isOk(
        await myFactory.isApprovedForAll(owner, owner)
      );
    });

    it('should not approve non-owner as _owner', async () => {
      assert.isNotOk(
        await myFactory.isApprovedForAll(userA, owner)
      );
      assert.isNotOk(
        await myFactory.isApprovedForAll(userB, userA)
      );
    });

    it('should not approve non-proxy address as _operator', async () => {
      assert.isNotOk(
        await myFactory.isApprovedForAll(owner, userB)
      );
    });

    it('should approve proxy address as _operator', async () => {
      assert.isOk(
        await myFactory.isApprovedForAll(owner, proxyForOwner)
      );
    });

    it('should reject proxy as _operator for non-owner _owner', async () => {
      assert.isNotOk(
        await myFactory.isApprovedForAll(userA, proxyForOwner)
      );
    });
  });

  /**
   * NOTE: This check is difficult to test in a development
   * environment, due to the OwnableDelegateProxy. To get around
   * this, in order to test this function below, you'll need to:
   *
   * 1. go to CreatureAccessoryFactory.sol, and
   * 2. modify _isOwnerOrProxy
   *
   * --> Modification is:
   *      comment out
   *         return owner() == _address || address(proxyRegistry.proxies(owner())) == _address;
   *      replace with
   *         return true;
   * Then run, you'll get the reentrant error, which passes the test
   **/

  describe('Re-Entrancy Check', () => {
    it('Should have the correct factory address set',
       async () => {
         assert.equal(await attacker.factoryAddress(), myFactory.address);
       });

    // With unmodified code, this fails with:
    //   CreatureAccessoryFactory#_mint: CANNOT_MINT_MORE
    // which is the correct behavior (no reentrancy) for the wrong reason
    // (the attacker is not the owner or proxy).

    xit('Minting from factory should disallow re-entrancy attack',
       async () => {
         await truffleAssert.passes(
           myFactory.mint(1, userA, 1, "0x0", { from: owner })
         );
         await truffleAssert.passes(
           myFactory.mint(1, userA, 1, "0x0", { from: userA })
         );
         await truffleAssert.fails(
           myFactory.mint(
             1,
             attacker.address,
             1,
             "0x0",
             { from: attacker.address }
           ),
           truffleAssert.ErrorType.revert,
           'ReentrancyGuard: reentrant call'
         );
       });
  });
});
