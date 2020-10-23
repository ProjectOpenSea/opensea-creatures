pragma solidity ^0.5.11;

import "./ERC1155Tradable.sol";

/**
 * @title CreatureAccessory
 * CreatureAccessory - a contract for Creature Accessory semi-fungible tokens.
 */
contract CreatureAccessory is ERC1155Tradable {
    constructor(address _proxyRegistryAddress)
        public
        ERC1155Tradable(
            "OpenSea Creature Accessory",
            "OSCA",
            _proxyRegistryAddress
        )
    {
        _setBaseMetadataURI("https://creatures-api.opensea.io/api/accessory/");
    }

    function contractURI() public pure returns (string memory) {
        return "https://creatures-api.opensea.io/contract/opensea-erc1155";
    }
}
