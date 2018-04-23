pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title CryptoPenguin
 * CryptoPenguin - a contract for my non-fungible crypto penguins.
 */
contract CryptoPenguin is ERC721Token, Ownable {
    
    // Mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;

    string public constant NAME = "CryptoPenguin";
    string public constant SYMBOL = "PENG";

    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    */
    function mintTo(address _to, string _tokenURI) public onlyOwner {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        tokenURIs[newTokenId] = _tokenURI;
    }

    /**
    * @dev returns the name ETHMOJI
    * @return string ETHMOJI
    */
    function name() public pure returns (string) {
        return NAME;
    }

    /**
    * @dev returns the name EMJ
    * @return string EMJ
    */
    function symbol() public pure returns (string) {
        return SYMBOL;
    }

    /**
    * @dev Returns an URI for a given token ID
    * @param _tokenId uint256 ID of the token to query
    */
    function tokenURI(uint256 _tokenId) public view returns (string) {
        return tokenURIs[_tokenId];
    }

    /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
    function _getNextTokenId() private view returns (uint256) {
        return totalSupply().add(1); 
    }
}