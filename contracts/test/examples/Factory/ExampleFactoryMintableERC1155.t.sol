// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../../testhelpers/DSTestPlusPlus.sol";
import {ExampleERC1155FactoryMintable} from "../../../examples/Factory/ExampleERC1155FactoryMintable.sol";
import {TokenFactory} from "../../../common/factory/TokenFactory.sol";
import {ERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract ExampleERC1155FactoryMintableTest is DSTestPlusPlus, ERC1155Receiver {
    ExampleERC1155FactoryMintable test;

    function setUp() public {
        test = new ExampleERC1155FactoryMintable(
            "test",
            "TEST",
            "://test",
            10000,
            address(1),
            "://option",
            100
        );
    }

    function testConstructorInitializesValues() public {
        assertEq("://test", test.uri(0));
        assertEq(address(1), test.proxyRegistryAddress());
        TokenFactory factory = TokenFactory(test.tokenFactory());
        assertEq("://option", factory.baseOptionURI());
        assertEq(100, factory.NUM_OPTIONS());
    }

    function testFactoryMint() public {
        vm.prank(address(test.tokenFactory()));
        test.factoryMint(1, address(this));
        assertEq(test.balanceOf(address(this), 0), 1);
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

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
