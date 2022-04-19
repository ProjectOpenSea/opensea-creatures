// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import {ERC721FactoryMintable} from "../../common/factory/ERC721FactoryMintable.sol";
import {ReentrancyGuard} from "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract ExampleERC721FactoryMintable is
    ERC721FactoryMintable,
    ReentrancyGuard
{
    using Strings for uint256;

    uint256 public tokenIndex;
    uint256 public maxSupply;

    error NewMaxSupplyMustBeGreater();

    constructor(
        uint256 _maxSupply,
        address _proxy,
        uint16 _numOptions
    )
        ERC721FactoryMintable(
            "test",
            "TEST",
            "ipfs://test",
            _proxy,
            "ipfs://option",
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
        for (uint256 i; i < _optionId + 1; ++i) {
            _mint(_to, _tokenIndex);
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
        if ((_optionId + 1) > (maxSupply - tokenIndex)) {
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
