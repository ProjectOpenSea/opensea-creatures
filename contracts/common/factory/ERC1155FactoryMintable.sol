// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {FactoryMintable} from "./FactoryMintable.sol";
import {AllowsProxyFromRegistry} from "../../common/lib/AllowsProxyFromRegistry.sol";
import {TokenFactory} from "./TokenFactory.sol";

abstract contract ERC1155FactoryMintable is
    ERC1155,
    FactoryMintable,
    AllowsProxyFromRegistry
{
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint16 _numOptions
    )
        ERC1155(_baseUri)
        FactoryMintable(
            new TokenFactory(
                string.concat(_name, " Factory"),
                string.concat(_symbol, "FACTORY"),
                _baseOptionURI,
                msg.sender, // pass msg.sender as owner to TokenFactory, owner is 0 in constructor
                _numOptions,
                _proxyAddress
            )
        )
        AllowsProxyFromRegistry(_proxyAddress)
    {}

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return
            isProxyOfOwner(_owner, _operator) ||
            super.isApprovedForAll(_owner, _operator);
    }
}
