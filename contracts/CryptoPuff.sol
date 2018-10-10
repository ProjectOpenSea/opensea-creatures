pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title CryptoPuff
 * CryptoPuff - a contract for my non-fungible crypto puffs.
 */
contract CryptoPuff is ERC721Token, Ownable {
  address proxyRegistryAddress;

  constructor(address _proxyRegistryAddress) ERC721Token("CryptoPuff", "PUFF") public {
    proxyRegistryAddress = _proxyRegistryAddress;
  }

  /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    */
  function mintTo(address _to, string _tokenURI) public onlyOwner {
    uint256 newTokenId = _getNextTokenId();
    _mint(_to, newTokenId);
    _setTokenURI(newTokenId, _tokenURI);
  }

  /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
  function _getNextTokenId() private view returns (uint256) {
    return totalSupply().add(1);
  }

  /**
   * 
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (proxyRegistry.proxies(owner) == operator) {
        return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}