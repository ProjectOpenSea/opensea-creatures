// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import "../CreatureAccessoryFactory.sol";


contract TestForReentrancyAttack is IERC1155Receiver {
    // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_RECEIVED_SIG = 0xf23a6e61;
    // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
    bytes4 constant internal ERC1155_BATCH_RECEIVED_SIG = 0xbc197c81;
    // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
    bytes4 constant internal INTERFACE_ERC1155_RECEIVER_FULL = 0x4e2312e0;
    //bytes4(keccak256('supportsInterface(bytes4)'))
    bytes4 constant internal INTERFACE_ERC165 = 0x01ffc9a7;

    address public factoryAddress;
    uint256 private totalToMint;

    constructor() {}

    function setFactoryAddress(address _factoryAddress) external {
        factoryAddress = _factoryAddress;
        totalToMint = 3;
    }

    /*function attack(uint256 _totalToMint) external {
        require(_totalToMint >= 2, "_totalToMint must be >= 2");
        totalToMint = _totalToMint;
        CreatureAccessoryFactory(factoryAddress).mint(1, address(this), 1, "");
        }*/

    // We attempt a reentrancy attack here by recursively calling the
    // CreatureAccessoryFactory that created the CreatureAccessory ERC1155 token
    // that we are receiving here.
    // We expect this to fail if the CreatureAccessoryFactory.mint() function
    // defends against reentrancy.

    function onERC1155Received(
        address /*_operator*/,
        address /*_from*/,
        uint256 _id,
        uint256 /*_amount*/,
        bytes calldata /*_data*/
    )
        override
        external
        returns(bytes4)
    {
        uint256 balance = IERC1155(msg.sender).balanceOf(address(this), _id);
        if(balance < totalToMint)
        {
            // 1 is the factory lootbox option, not the token id
            CreatureAccessoryFactory(factoryAddress)
                .mint(1, address(this), 1, "");
        }
        return ERC1155_RECEIVED_SIG;
    }

    function supportsInterface(bytes4 interfaceID)
        override
        external
        pure
        returns (bool)
    {
        return interfaceID == INTERFACE_ERC165 ||
            interfaceID == INTERFACE_ERC1155_RECEIVER_FULL;
    }

    // We don't use this but we need it for the interface

    function onERC1155BatchReceived(address /*_operator*/, address /*_from*/, uint256[] memory /*_ids*/, uint256[] memory /*_values*/, bytes memory /*_data*/)
        override public pure returns(bytes4)
    {
        return ERC1155_BATCH_RECEIVED_SIG;
    }
}
