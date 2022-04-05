// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

library StringUtil {
    function stringEqual(string memory _string1, string memory _string2)
        internal
        pure
        returns (bool)
    {
        return
            bytes(_string1).length == bytes(_string2).length &&
            keccak256(bytes(_string1)) == keccak256(bytes(_string2));
    }
}
