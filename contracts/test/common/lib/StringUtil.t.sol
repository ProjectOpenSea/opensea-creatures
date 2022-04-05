// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {StringUtil} from "../../../common/lib/StringUtil.sol";
import {DSTestPlus} from "@rari-capital/solmate/src/test/utils/DSTestPlus.sol";

contract TestStringUtil is DSTestPlus {
    function testStringEqual() public {
        assertTrue(StringUtil.stringEqual("", ""));
        assertTrue(StringUtil.stringEqual("abc", "abc"));
        assertFalse(StringUtil.stringEqual("abc", "abcd"));
        assertFalse(StringUtil.stringEqual("abcf", "abcd"));
        assertTrue(
            StringUtil.stringEqual(
                string(bytes(hex"0000")),
                string(bytes(hex"0000"))
            )
        );
        assertFalse(
            StringUtil.stringEqual(
                string(bytes(hex"0000")),
                string(bytes(hex"000000"))
            )
        );
        assertFalse(
            StringUtil.stringEqual(
                string(bytes(hex"0000")),
                string(bytes(hex"ffff"))
            )
        );
    }
}
