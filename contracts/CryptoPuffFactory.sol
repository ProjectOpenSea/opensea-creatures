pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './Factory.sol';
import './CryptoPuff.sol';
import './CryptoPuffLootBox.sol';
import './Strings.sol';

contract CryptoPuffFactory is Factory, Ownable {
  using Strings for string;

  address proxyRegistryAddress;
  address nftAddress;
  address lootBoxNftAddress;
  string public baseURI = "https://cryptopuffs-api.herokuapp.com/api/factory/";

  /**
   * Enforce the existence of only 100 cryptopuffs (not including those created through lootboxes).
   */
  uint256 PUFF_SUPPLY = 100;

  /**
   * Lootbox supply.
   */
  uint256 LOOTBOX_SUPPLY = 5;

  /**
   * Three different options for minting CryptoPuffs (basic, premium, and gold).
   */
  uint256 NUM_OPTIONS = 3;
  uint256 LOOTBOX_OPTION = 2;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
    lootBoxNftAddress = new CryptoPuffLootBox(_proxyRegistryAddress, this);
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }
  
  function mint(uint256 _optionId, address _toAddress) external {
    require(msg.sender == owner || msg.sender == lootBoxNftAddress);

    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(proxyRegistry.proxies(owner) == msg.sender || owner == msg.sender);
    require(canMint(_optionId));

    // Option 2 is a lootbox.
    if (_optionId == LOOTBOX_OPTION) {
      CryptoPuffLootBox cryptoPuffLootBox = CryptoPuffLootBox(lootBoxNftAddress);
      cryptoPuffLootBox.mintTo(_toAddress);
    } else {
      CryptoPuff cryptoPuff = CryptoPuff(nftAddress);
      cryptoPuff.mintTo(_toAddress);
    }
  }

  function canMint(uint256 _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    // Case: lootbox option.
    uint256 currentSupply = 0;
    if (_optionId == LOOTBOX_OPTION) {
      CryptoPuffLootBox cryptoPuffLootBox = CryptoPuffLootBox(lootBoxNftAddress);
      currentSupply = cryptoPuffLootBox.totalSupply();
      return currentSupply < (LOOTBOX_SUPPLY - 1);
    }

    CryptoPuff cryptoPuff = CryptoPuff(nftAddress);
    currentSupply = cryptoPuff.totalSupply();
    return currentSupply < (PUFF_SUPPLY - 1);
  }
  
  function tokenURI(uint256 _optionId) public view returns (string) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }
}