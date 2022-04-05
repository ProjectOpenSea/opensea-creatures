//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SingleMintERC721 is ERC721, Ownable {
    mapping(uint256 => string) public tokenURIs;

    error TokenIDAlreadyExists();
    error EmptyTokenURI();

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenURIs[_tokenId];
    }

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
        if (!_stringEqual(tokenURIs[_tokenId], "")) {
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

    function _stringEqual(string memory _string1, string memory _string2)
        internal
        pure
        returns (bool)
    {
        return
            bytes(_string1).length == bytes(_string2).length &&
            keccak256(bytes(_string1)) == keccak256(bytes(_string2));
    }
}
