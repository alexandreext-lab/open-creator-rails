// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAsset} from "./IAsset.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Asset is Ownable, IAsset {
    bytes32 public immutable assetId;
    uint256 public immutable subscriptionPrice;
    mapping(address => uint256) public subscriptions;
    IERC20 public immutable token;
    
    error SubscriptionFailed();

    event SubscriptionAdded(address indexed user, uint256 expiresAt);
    event SubscriptionRevoked(address indexed user);
    
    constructor(bytes32 _assetId, uint256 _subscriptionPrice, IERC20 _token) Ownable(msg.sender) {
        assetId = _assetId;
        subscriptionPrice = _subscriptionPrice;
        token = _token;
    }

    function getAssetId() external view returns (bytes32) {
        return assetId;
    }

    function getSubscriptionPrice(uint256 duration) external view returns (uint256) {
        return subscriptionPrice * duration;
    }

    function getSubscription(address user) external view returns (uint256) {
        return subscriptions[user];
    }

    function viewSubscription(address user) external view returns (bool) {
        return subscriptions[user] > block.timestamp;
    }

    function subscribe(uint256 duration) external returns (bool) {
        uint256 price = getSubscriptionPrice(duration);

        if (token.allowance(msg.sender, address(this)) < price) {
            revert SubscriptionFailed();
        }
        
        token.transferFrom(msg.sender, address(this), price);
        subscriptions[msg.sender] = block.timestamp + duration;
        emit SubscriptionAdded(msg.sender, subscriptions[msg.sender]);
        return true;
    }

    function revokeSubscription(address user) external returns (bool) {
        uint256 duration = subscriptions[user];
        if (duration == 0) {
            return false;
        }
        delete subscriptions[user];
        emit SubscriptionRevoked(user);
        return true;
    }
}