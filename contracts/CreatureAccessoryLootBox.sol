// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./ERC1155Tradable.sol";
import "./LootBoxRandomness.sol";


/**
 * @title CreatureAccessoryLootBox
 * CreatureAccessoryLootBox - a randomized and openable lootbox of Creature
 * Accessories.
 */
contract CreatureAccessoryLootBox is ERC1155Tradable, ReentrancyGuard {
  using LootBoxRandomness for LootBoxRandomness.LootBoxRandomnessState;
  using SafeMath for uint256;

  LootBoxRandomness.LootBoxRandomnessState state;

  /**
   * @dev Example constructor. Sets minimal configuration.
   * @param _proxyRegistryAddress The address of the OpenSea/Wyvern proxy registry
   *                              On Rinkeby: "0xf57b2c51ded3a29e6891aba85459d600256cf317"
   *                              On mainnet: "0xa5409ec958c83c3f309868babaca7c86dcb077c1"
   */
  constructor(address _proxyRegistryAddress)
  ERC1155Tradable(
    "OpenSea Creature Accessory Loot Box",
    "OSCALOOT",
    "",
    _proxyRegistryAddress
  ) {}

  function setState(
    address _factoryAddress,
    uint256 _numOptions,
    uint256 _numClasses,
    uint256 _seed
  ) public onlyOwner {
    LootBoxRandomness.initState(state, _factoryAddress, _numOptions, _numClasses, _seed);
  }

  function setTokenIdsForClass(
    uint256 _classId,
    uint256[] memory _tokenIds
  ) public onlyOwner {
      LootBoxRandomness.setTokenIdsForClass(state, _classId, _tokenIds);
  }

  function setOptionSettings(
    uint256 _option,
    uint256 _maxQuantityPerOpen,
    uint16[] memory _classProbabilities,
    uint16[] memory _guarantees
  ) public onlyOwner {
    LootBoxRandomness.setOptionSettings(state, _option, _maxQuantityPerOpen, _classProbabilities, _guarantees);
  }

  ///////
  // MAIN FUNCTIONS
  //////

  function unpack(
    uint256 _optionId,
    address _toAddress,
    uint256 _amount
  ) external {
    // This will underflow if _msgSender() does not own enough tokens.
    _burn(_msgSender(), _optionId, _amount);
    // Mint nfts contained by LootBox
    LootBoxRandomness._mint(state, _optionId, _toAddress, _amount, "", address(this));
  }

  /**
   *  @dev Mint the token/option id.
   */
  function mint(
    address _to,
    uint256 _optionId,
    uint256 _amount,
    bytes memory _data
  ) override public nonReentrant {
    require(_isOwnerOrProxy(_msgSender()), "Lootbox: owner or proxy only");
    require(_optionId < state.numOptions, "Lootbox: Invalid Option");
    // Option ID is used as a token ID here
    _mint(_to, _optionId, _amount, _data);
  }

  /**
   *  @dev track the number of tokens minted.
   */
  function _mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) override internal  {
    tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    super._mint(_to, _id, _quantity, _data);
  }

  function _isOwnerOrProxy(
    address _address
  ) internal view returns (bool) {
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    return owner() == _address || address(proxyRegistry.proxies(owner())) == _address;
  }
}
