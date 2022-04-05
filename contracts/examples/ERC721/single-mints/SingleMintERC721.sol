// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AllowsProxyFromRegistry} from "../../../common/lib/AllowsProxyFromRegistry.sol";
import {StringUtil} from "../../../common/lib/StringUtil.sol";

contract SingleMintERC721 is ERC721, Ownable, AllowsProxyFromRegistry {
    mapping(uint256 => string) public tokenURIs;

    error TokenIDAlreadyExists();

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) ERC721(_name, _symbol) AllowsProxyFromRegistry(_proxyRegistryAddress) {}

    function mint(uint256 _tokenId, string calldata _tokenURI)
        public
        onlyOwner
    {
        return mint(owner(), _tokenId, _tokenURI);
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _tokenURI
    ) public onlyOwner {
        if (!StringUtil.stringEqual(tokenURIs[_tokenId], "")) {
            revert TokenIDAlreadyExists();
        }
        tokenURIs[_tokenId] = _tokenURI;
        ERC721._mint(_to, _tokenId);
    }

    function setTokenURI(uint256 _tokenId, string calldata _tokenURI)
        public
        onlyOwner
    {
        tokenURIs[_tokenId] = _tokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenURIs[_tokenId];
    }
}
