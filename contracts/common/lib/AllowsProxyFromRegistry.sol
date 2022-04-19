// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ProxyRegistry} from "./ProxyRegistry.sol";

///@notice Checks approval against a single proxy address configured at deploy for gas-free trading on a marketplace
contract AllowsProxyFromRegistry is Ownable {
    enum ProxyRegistryState {
        ACTIVE,
        INACTIVE
    }

    address public immutable proxyRegistryAddress;
    ProxyRegistryState public proxyRegistryState = ProxyRegistryState.ACTIVE;

    constructor(address _proxyRegistryAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    ///@notice toggles proxy check in isApprovedForProxy. Proxy can be disabled in emergency circumstances. OnlyOwner
    function setProxyRegistryState(ProxyRegistryState _proxyRegistryState)
        external
        onlyOwner
    {
        proxyRegistryState = _proxyRegistryState;
    }

    ///@dev to be used in conjunction with isApprovedForAll in token contracts
    ///@param _owner address of token owner
    ///@param _operator address of operator
    ///@return bool true if operator is approved
    function isProxyOfOwner(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (
            proxyRegistryState == ProxyRegistryState.ACTIVE &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }
        return false;
    }
}
