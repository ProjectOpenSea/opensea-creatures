// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlus} from "@rari-capital/solmate/src/test/utils/DSTestPlus.sol";
import {Vm, stdCheats} from "forge-std/stdlib.sol";

contract DSTestPlusPlus is DSTestPlus, stdCheats {
    Vm public constant vm = Vm(HEVM_ADDRESS);
}
