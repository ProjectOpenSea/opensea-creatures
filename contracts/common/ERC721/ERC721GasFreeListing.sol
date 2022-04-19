// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AllowsProxyFromRegistry} from "../lib/AllowsProxyFromRegistry.sol";
import {StringUtil} from "../lib/StringUtil.sol";

// todo: inheritance diagram
contract ERC721GasFreeListing is ERC721, AllowsProxyFromRegistry {
    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) ERC721(_name, _symbol) AllowsProxyFromRegistry(_proxyRegistryAddress) {}

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            isProxyOfOwner(_owner, _operator) ||
            super.isApprovedForAll(_owner, _operator);
    }
}
