// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../../testhelpers/DSTestPlusPlus.sol";
import {ExampleERC721FactoryMintable} from "../../../examples/Factory/ExampleERC721FactoryMintable.sol";
import {TokenFactory} from "../../../common/factory/TokenFactory.sol";

contract ExampleERC721FactoryMintableTest is DSTestPlusPlus {
    ExampleERC721FactoryMintable test;

    function setUp() public {
        test = new ExampleERC721FactoryMintable(10000, address(1), 100);
    }

    function testConstructorInitializesValues() public {
        assertEq("test", test.name());
        assertEq("TEST", test.symbol());
        assertEq("ipfs://test", test.baseURI());
        assertEq(address(1), test.proxyRegistryAddress());
        TokenFactory factory = TokenFactory(test.tokenFactory());
        assertEq("ipfs://option", factory.baseOptionURI());
        assertEq(100, factory.NUM_OPTIONS());
    }

    function testFactoryMint() public {
        vm.prank(address(test.tokenFactory()));
        test.factoryMint(1, address(this));
        assertEq(test.ownerOf(0), address(this));
    }

    function testFactoryMintOnlyFactory() public {
        vm.expectRevert(errorSig("NotTokenFactory()"));
        test.factoryMint(1, address(this));
    }

    function testFactoryMintCanMint() public {
        vm.startPrank(address(test.tokenFactory()));
        vm.expectRevert(errorSig("FactoryCannotMint()"));
        test.factoryMint(1000000, address(this));
        test.factoryMint(5, address(this));
        vm.expectRevert(errorSig("FactoryCannotMint()"));
        test.factoryMint(9999, address(this));
    }

    function testFactoryCanMint() public {
        assertTrue(test.factoryCanMint(1));
        assertFalse(test.factoryCanMint(10000000));
        assertTrue(test.factoryCanMint(0));
    }

    function testSetMaxSupply() public {
        assertEq(10000, test.maxSupply());
        test.setMaxSupply(10001);
        assertEq(10001, test.maxSupply());
    }

    function testSetMaxSupplyMustBeGreater() public {
        vm.expectRevert(errorSig("NewMaxSupplyMustBeGreater()"));
        test.setMaxSupply(1);
    }

    function testSetMaxSupplyOnlyOwner() public {
        test.transferOwnership(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        test.setMaxSupply(10001);
    }
}
