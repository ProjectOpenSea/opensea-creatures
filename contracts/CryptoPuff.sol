pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title CryptoPuff
 * CryptoPuff - a contract for my non-fungible crypto puffs.
 */
contract CryptoPuff is ERC721Token, Ownable {
    function CryptoPuff() ERC721Token("CryptoPuff", "PUFF") public { }

    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    */
    function mintTo(address _to, string _tokenURI) public onlyOwner {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
    }

    /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
    function _getNextTokenId() private view returns (uint256) {
        return totalSupply().add(1); 
    }
}