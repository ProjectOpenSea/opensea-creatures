// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../../../testhelpers/DSTestPlusPlus.sol";
import {SingleMintERC721} from "../../../../examples/ERC721/single-mints/SingleMintERC721.sol";
import {StringUtil} from "../../../../common/lib/StringUtil.sol";

contract TestSingleMintERC721 is DSTestPlusPlus {
    SingleMintERC721 test;

    function setUp() public {
        test = new SingleMintERC721("TestSingleMintERC721", "TST", address(0));
    }

    function testConstructor() public {
        assertEq(test.name(), "TestSingleMintERC721");
        assertEq(test.symbol(), "TST");
    }

    function testMint() public {
        string memory uri = "example";
        test.mint(1, uri);
        assertEq(address(this), test.ownerOf(1));
        assertEq(uri, test.tokenURI(1));

        uri = "example2";
        test.mint(address(1234), 2, uri);
        assertEq(address(1234), test.ownerOf(2));
        assertEq(uri, test.tokenURI(2));

        vm.expectRevert(SingleMintERC721.TokenIDAlreadyExists.selector);
        test.mint(1, uri);
    }

    function testMint_onlyOwner() public {
        test.transferOwnership(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        test.mint(1, "example");
        vm.prank(address(1234));
        test.mint(1, "example");
        assertEq(address(1234), test.ownerOf(1));
    }
}
