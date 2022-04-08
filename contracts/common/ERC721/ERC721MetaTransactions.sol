// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable, Context} from "@openzeppelin/contracts/access/Ownable.sol";

import {AllowsProxyFromRegistry} from "../lib/AllowsProxyFromRegistry.sol";
import {StringUtil} from "../lib/StringUtil.sol";
import {ERC721GasFreeListing} from "./ERC721GasFreeListing.sol";
import {ContextMixin} from "../meta-transactions/ContextMixin.sol";
import {NativeMetaTransaction} from "../meta-transactions/NativeMetaTransaction.sol";

// todo: inheritance diagram
contract ERC721MetaTransactions is
    ERC721GasFreeListing,
    ContextMixin,
    NativeMetaTransaction
{
    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) ERC721GasFreeListing(_name, _symbol, _proxyRegistryAddress) {
        _initializeEIP712(_name);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        view
        override(Context, ContextMixin)
        returns (address sender)
    {
        return ContextMixin._msgSender();
    }
}
