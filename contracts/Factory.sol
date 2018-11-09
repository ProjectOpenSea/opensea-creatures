pragma solidity ^0.4.24;

/**
 * This is a generic factory contract that can be used to mint tokens. The configuration
 * for minting is specified by an _optionId, which can be used to delineate various 
 * ways of minting.
 */
interface Factory {
  /**
   * Returns the name of this factory.
   */
  function name() external view returns (string);

  /**
   * Returns the symbol for this factory.
   */
  function symbol() external view returns (string);

  /**
   * Number of options the factory supports.
   */
  function numOptions() public view returns (uint256);

  /**
   * @dev Returns whether the option ID can be minted. Can return false if the developer wishes to
   * restrict a total supply per option ID (or overall).
   */
  function canMint(uint256 _optionId) public view returns (bool);

  /**
   * @dev Returns a URL specifying some metadata about the option. This metadata can be of the
   * same structure as the ERC721 metadata.
   */
  function tokenURI(uint256 _optionId) public view returns (string);

  /**
   * Indicates that this is a factory contract. Ideally would use EIP 165 supportsInterface()
   */
  function supportsFactoryInterface() public view returns (bool);

  /**
    * @dev Mints asset(s) in accordance to a specific address with a particular "option". This should be 
    * callable only by the contract owner or the owner's Wyvern Proxy (later universal login will solve this).
    * Options should also be delineated 0 - (numOptions() - 1) for convenient indexing.
    * @param _optionId the option id
    * @param _toAddress address of the future owner of the asset(s)
    */
  function mint(uint256 _optionId, address _toAddress) external;
}