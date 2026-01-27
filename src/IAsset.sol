// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAsset {
    
    function getAssetId() external view returns (bytes32);
    
    function getSubscriptionPrice(uint256 duration) external view returns (uint256);
    
    function getSubscription(address user) external view returns (uint256);
    
    function viewSubscription(address user) external view returns (bool);
    
    function subscribe(uint256 duration) external;
    
    function revokeSubscription(address user) external returns (bool);
}