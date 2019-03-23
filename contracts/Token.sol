pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * @title CreatureToken
 * CreatureToken - a simple contract for a token that can be used to buy and sell creatures.
 */
contract CreatureToken is MintableToken {
  string public constant name = "Creature Token";
  string public constant symbol = "CRT";
  uint8 public constant decimals = 18;
}