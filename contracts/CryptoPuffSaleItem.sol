pragma solidity ^0.4.21;

import "./TradeableERC721Token.sol";
import "./CryptoPuff.sol";
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title CryptoPuffSaleItem
 *
 * CryptoPuffSaleItem - a tradeable loot box of CryptoPuffs.
 */
contract CryptoPuffSaleItem is TradeableERC721Token {
    address nftAddress;

    constructor(address _proxyRegistryAddress) TradeableERC721Token("CryptoPuff", "PUFF", _proxyRegistryAddress) public {
        // Note that the loot box contract will be the owner of the CryptoPuff contract. This may not be ideal.
        nftAddress = new CryptoPuff(_proxyRegistryAddress);
    }

    function unpack(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);
    
        // Mint the ERC721 item(s).
        CryptoPuff cryptoPuff = CryptoPuff(nftAddress);
        
        // TODO: properly generate the metadata URL, or better configure the CryptoPuff contract to dynamically generate it.
        cryptoPuff.mintTo(msg.sender, "https://cryptopuffs-api.herokuapp.com/api/puff/");
        
        // TODO: Custom logic for configuring the item (include your randomness here!)

        // Burn the presale item.
        _burn(msg.sender, _tokenId);
    }
}