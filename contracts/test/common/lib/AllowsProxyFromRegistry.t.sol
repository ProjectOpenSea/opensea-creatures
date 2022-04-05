// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../../testhelpers/DSTestPlusPlus.sol";
import {User} from "../../testhelpers/User.sol";
import {AllowsProxyFromRegistry} from "../../../common/lib/AllowsProxyFromRegistry.sol";
import {ProxyRegistry, OwnableDelegateProxy} from "../../../common/lib/ProxyRegistry.sol";

contract TestProxyRegistry is ProxyRegistry {
    function createProxy(address _owner, address _operator) external {
        proxies[_owner] = OwnableDelegateProxy(_operator);
    }
}

contract AllowsProxyFromRegistryImpl is AllowsProxyFromRegistry {
    constructor(address _proxyRegistry)
        AllowsProxyFromRegistry(_proxyRegistry)
    {}

    function isApprovedForProxy(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return _isApprovedForProxy(_owner, _operator);
    }
}

contract AllowsProxyFromImmutableRegistryTest is DSTestPlusPlus {
    AllowsProxyFromRegistryImpl test;
    TestProxyRegistry proxyRegistry;
    User user = new User();

    function setUp() public {
        proxyRegistry = new TestProxyRegistry();
        test = new AllowsProxyFromRegistryImpl(address(proxyRegistry));
    }

    function testConstructorInitializesProperties() public {
        assertTrue(
            test.proxyRegistryState() ==
                AllowsProxyFromRegistry.ProxyRegistryState.ACTIVE
        );
        assertEq(address(proxyRegistry), test.proxyRegistryAddress());
    }

    function testSetProxyRegistryState() public {
        assertTrue(
            test.proxyRegistryState() ==
                AllowsProxyFromRegistry.ProxyRegistryState.ACTIVE
        );
        test.setProxyRegistryState(
            AllowsProxyFromRegistry.ProxyRegistryState.INACTIVE
        );
        assertFalse(
            test.proxyRegistryState() ==
                AllowsProxyFromRegistry.ProxyRegistryState.ACTIVE
        );
    }

    function testSetProxyRegistryState_onlyOwner() public {
        test.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        test.setProxyRegistryState(
            AllowsProxyFromRegistry.ProxyRegistryState.INACTIVE
        );
    }

    function testIsProxyOfOwner() public {
        assertFalse(test.isApprovedForProxy(address(user), address(this)));
        proxyRegistry.createProxy(address(user), address(this));
        assertTrue(test.isApprovedForProxy(address(user), address(this)));
        // test returns false when proxy registry is inactive
        test.setProxyRegistryState(
            AllowsProxyFromRegistry.ProxyRegistryState.INACTIVE
        );
        assertFalse(test.isApprovedForProxy(address(user), address(this)));
    }
}
