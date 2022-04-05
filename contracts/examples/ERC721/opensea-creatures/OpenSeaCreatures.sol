// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC721GasFreeListing} from "../../../common/ERC721/ERC721GasFreeListing.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract OpenSeaCreatures is ERC721GasFreeListing {
    constructor(address _proxyRegistryAddress)
        ERC721GasFreeListing("OpenSeaCreatures", "OSC", _proxyRegistryAddress)
    {}

    function baseTokenURI() public pure returns (string memory) {
        return "https://opensea-creatures-api.herokuapp.com/api/creature/";
    }
}
