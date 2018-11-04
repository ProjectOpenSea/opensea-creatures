pragma solidity ^0.4.24;

import './TradeableERC721Token.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title CryptoPuff
 * CryptoPuff - a contract for my non-fungible crypto puffs.
 */
contract CryptoPuff is TradeableERC721Token {
  string public baseURI = "https://cryptopuffs-api.herokuapp.com/api/puff/";

  constructor(address _proxyRegistryAddress) TradeableERC721Token("CryptoPuff", "PUFF", _proxyRegistryAddress) public {  }
}