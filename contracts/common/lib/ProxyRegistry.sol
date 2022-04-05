// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
@notice Basic interface for looking up the OwnableDelegateProxy contracts associated with users in the registry
*/
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
@notice This empty contract serves as a descriptive name for the proxy smart contract deployed at the addresses
    contained within the `proxies` mapping in the registry
*/
contract OwnableDelegateProxy {

}
