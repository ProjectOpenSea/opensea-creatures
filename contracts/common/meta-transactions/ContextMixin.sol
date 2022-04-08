// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

abstract contract ContextMixin is Context {
    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}
