pragma solidity ^0.5.11;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "multi-token-standard/contracts/tokens/ERC1155/ERC1155MintBurn.sol";
import "./LootBoxRandomness.sol";


/**
 * @title CreatureAccessoryLootBox
 * CreatureAccessoryLootBox - a randomized and openable lootbox of Creature
 * Accessories.
 */
contract CreatureAccessoryLootBox is ERC1155MintBurn, Ownable, ReentrancyGuard {
  using LootBoxRandomness for LootBoxRandomness.LootBoxRandomnessState;

  LootBoxRandomness.LootBoxRandomnessState state;

  address proxyRegistryAddress;
  // Contract name
  string public name;
  // Contract symbol
  string public symbol;
  mapping (uint256 => uint256) tokenSupply;

  /**
   * @dev Example constructor. Sets minimal configuration.
   * @param _proxyRegistryAddress The address of the OpenSea/Wyvern proxy registry
   *                              On Rinkeby: "0xf57b2c51ded3a29e6891aba85459d600256cf317"
   *                              On mainnet: "0xa5409ec958c83c3f309868babaca7c86dcb077c1"
   */
  constructor(address _proxyRegistryAddress) public {
      name = "OpenSea Creature Accessory Loot Box";
      symbol = "OSCALOOT";
      proxyRegistryAddress = _proxyRegistryAddress;
  }

  function setState(
    address _nftAddress,
    uint256 _numOptions,
    uint256 _numClasses,
    uint256 _seed
  ) public onlyOwner {
    LootBoxRandomness.initState(state, _nftAddress, _numOptions, _numClasses, _seed);
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

  function open(
    uint256 _optionId,
    address _toAddress,
    uint256 _amount
  ) external {
    require(_optionId < state.numOptions, "Lootbox: Invalid Option");
    // Note that we burn the token id but mint the option id.
    uint256 optionTokenId = _optionId + 1;
    // This will underflow if msg.sender does not own enough tokens.
    _burn(msg.sender, optionTokenId, _amount);
    // Mint nfts contained by LootBox
    LootBoxRandomness._mint(state, _optionId, _toAddress, _amount, "", address(this));
  }

  /**
   *  @dev Mint the *option* id, not a token id.
   */
  function mintForOption(
    address _to,
    uint256 _optionId,
    uint256 _amount,
    bytes memory _data
  ) public nonReentrant {
    require(_isOwnerOrProxy(msg.sender), "Lootbox: owner or proxy only");
    require(_optionId < state.numOptions, "Lootbox: Invalid Option");
    uint256 optionTokenId = _optionId + 1;
    _mint(_to, optionTokenId, _amount, _data);
  }

  /**
   *  @dev track the number of tokens minted.
   */
  function _mint(
    address _to,
    uint256 _id,
    uint256 _quantity,
    bytes memory _data
  ) internal  {
    tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    super._mint(_to, _id, _quantity, _data);
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  ) public view returns (bool isOperator) {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return ERC1155.isApprovedForAll(_owner, _operator);
  }

  function _isOwnerOrProxy(
    address _address
  ) internal view returns (bool) {
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    return owner() == _address || address(proxyRegistry.proxies(owner())) == _address;
  }

  /**
    * @dev Returns the total quantity for a token ID
    * @param _id uint256 ID of the token to query
    * @return amount of token in existence
    */
  function totalSupply(
    uint256 _id
  ) public view returns (uint256) {
    return tokenSupply[_id];
  }
}
