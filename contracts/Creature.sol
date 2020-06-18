pragma solidity ^0.5.0;

import "./ERC721Tradable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable {
  constructor(address _proxyRegistryAddress) ERC721Tradable("Creature", "OSC", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://creatures-api.opensea.io/api/creature/";
  }

  function contractURI() public view returns (string memory) {
    return "https://creatures-api.opensea.io/contract/opensea-creatures";
  }
}
