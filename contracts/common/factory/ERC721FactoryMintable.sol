// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {FactoryMintable} from "./FactoryMintable.sol";
import {AllowsProxyFromRegistry} from "../../common/lib/AllowsProxyFromRegistry.sol";
import {TokenFactory} from "./TokenFactory.sol";

abstract contract ERC721FactoryMintable is
    ERC721,
    Ownable,
    FactoryMintable,
    AllowsProxyFromRegistry
{
    using Strings for uint256;
    string public baseURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint16 _numOptions
    )
        ERC721(_name, _symbol)
        ///@dev mainnet: 0xa5409ec958c83c3f309868babaca7c86dcb077c1 rinkeby: 0x1e525eeaf261ca41b809884cbde9dd9e1619573a
        AllowsProxyFromRegistry(_proxyAddress)
        /// @dev construct a new TokenFactory and pass its address to the FactoryMintable constructor
        FactoryMintable(
            new TokenFactory(
                string.concat(_name, " Factory"),
                string.concat(_symbol, "FACTORY"),
                _baseOptionURI,
                msg.sender, // pass msg.sender as owner to TokenFactory - owner is 0 in constructor
                _numOptions,
                _proxyAddress
            )
        )
    {
        baseURI = _baseUri;
    }

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

    function factoryCanMint(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (bool);

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string.concat(baseURI, _tokenId.toString());
    }
}
