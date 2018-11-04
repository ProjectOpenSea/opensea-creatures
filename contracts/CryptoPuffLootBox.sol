pragma solidity ^0.4.21;

import "./TradeableERC721Token.sol";
import "./CryptoPuff.sol";
import "./Factory.sol";
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title CryptoPuffLootBox
 *
 * CryptoPuffLootBox - a tradeable loot box of CryptoPuffs.
 */
contract CryptoPuffLootBox is TradeableERC721Token {
    uint256 NUM_PUFFS_PER_BOX = 3;
    uint256 OPTION_ID = 0;
    address factoryAddress;

    constructor(address _proxyRegistryAddress, address _factoryAddress) TradeableERC721Token("CryptoPuffLootBox", "PUFFBOX", _proxyRegistryAddress) public {
        factoryAddress = _factoryAddress;
    }

    function unpack(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);

        // Insert custom logic for configuring the item here.
        for (uint256 i = 0; i < NUM_PUFFS_PER_BOX; i++) {
            // Mint the ERC721 item(s).
            Factory factory = Factory(factoryAddress);
            factory.mint(OPTION_ID, msg.sender);
        }

        // Burn the presale item.
        _burn(msg.sender, _tokenId);
    }

    function baseTokenURI() public view returns (string) {
        return "https://cryptopuffs-api.herokuapp.com/api/box/";
    }
}