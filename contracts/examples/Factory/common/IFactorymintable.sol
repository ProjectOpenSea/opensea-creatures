// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IFactoryMintable {
    function factoryMint(uint256 _optionId, address _to) external;

    function factoryCanMint(uint256 _optionId) external view returns (bool);
}
