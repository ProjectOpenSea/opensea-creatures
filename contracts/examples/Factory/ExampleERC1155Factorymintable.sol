// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import {ERC1155FactoryMintable} from "../../common/factory/ERC1155FactoryMintable.sol";
import {ReentrancyGuard} from "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";

contract ExampleERC1155FactoryMintable is
    ERC1155FactoryMintable,
    ReentrancyGuard
{
    uint256 public tokenIndex;
    uint256 public maxSupply;

    error NewMaxSupplyMustBeGreater();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        uint256 _maxSupply,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint16 _numOptions
    )
        ERC1155FactoryMintable(
            _name,
            _symbol,
            _baseUri,
            _proxyAddress,
            _baseOptionURI,
            _numOptions
        )
    {
        maxSupply = _maxSupply;
    }

    function factoryMint(uint256 _optionId, address _to)
        public
        override
        nonReentrant
        onlyFactory
        canMint(_optionId)
    {
        // load from storage, read+write to memory
        uint256 _tokenIndex = tokenIndex;
        for (uint256 i; i < _optionId; ++i) {
            _mint(_to, _tokenIndex, 1, "");
            ++_tokenIndex;
        }
        // single write to storage
        tokenIndex = _tokenIndex;
    }

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        override
        returns (bool)
    {
        if (_optionId + 1 > (maxSupply - tokenIndex)) {
            return false;
        }
        return true;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        if (_maxSupply <= maxSupply) {
            revert NewMaxSupplyMustBeGreater();
        }
        maxSupply = _maxSupply;
    }
}
