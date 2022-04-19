// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {VRFConsumerBase} from "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract VRFV1Consumer is VRFConsumerBase, Ownable {
    bytes32 public chainlinkKeyHash;
    uint256 public chainlinkFee;

    constructor(
        bytes32 _keyhash,
        address _vrfCoordinator,
        address _linkToken,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
        chainlinkKeyHash = _keyhash;
        chainlinkFee = _fee;
    }

    function setFee(uint256 _fee) public onlyOwner {
        chainlinkFee = _fee;
    }

    function setKeyHash(bytes32 _keyhash) public onlyOwner {
        chainlinkKeyHash = _keyhash;
    }

    function requestRandomness() public returns (bytes32 requestId) {
        return requestRandomness(chainlinkKeyHash, chainlinkFee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        virtual
        override;
}
