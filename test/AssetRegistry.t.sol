// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AssetRegistry} from "../src/AssetRegistry.sol";
import {IAsset} from "../src/IAsset.sol";
import {BaseTest} from "./Base.t.sol";

contract AssetRegistryTest is BaseTest {
    AssetRegistry public assetRegistry;

    uint256 internal constant SUBSCRIPTION_PRICE = 100000000;
    uint256 internal constant DURATION = 3600;

    bytes32 internal constant ASSET_ID = keccak256(abi.encodePacked("asset_id"));

    function setUp() public override {
        super.setUp();

        assetRegistry = new AssetRegistry(70, 30);
    }

    function test_createAsset() public {
        address asset = assetRegistry.createAsset(ASSET_ID, SUBSCRIPTION_PRICE, address(gameToken), signer);
        assertEq(IAsset(asset).getAssetId(), ASSET_ID);
        assertEq(asset, address(assetRegistry.assets(ASSET_ID)));
    }

    function test_getAsset() public {
        test_createAsset();
        address asset = assetRegistry.getAsset(ASSET_ID);
        assertEq(IAsset(asset).getAssetId(), ASSET_ID);
    }

    function test_subscribe() public {
        if (assetRegistry.assets(ASSET_ID) == address(0)) {
            test_createAsset();
        }
        
        address owner = signer;
        address spender = assetRegistry.getAsset(ASSET_ID);
        uint256 value = IAsset(spender).getSubscriptionPrice(DURATION);
        uint256 deadline = block.timestamp + DURATION;

        (uint8 v, bytes32 r, bytes32 s) = getPermit(owner, spender, value, deadline);        

        bool success = assetRegistry.subscribe(ASSET_ID, owner, spender, value, deadline, v, r, s);
        
        assertTrue(success);

        assertEq(IAsset(spender).getSubscription(owner), deadline);
    }

    function test_viewSubscription() public {
        test_createAsset();
        assertEq(assetRegistry.viewSubscription(ASSET_ID), false);
        test_subscribe();
        assertEq(assetRegistry.viewSubscription(ASSET_ID), true);
    }

    function test_getSubscription() public {
        test_createAsset();
        assertEq(assetRegistry.getSubscription(ASSET_ID), 0);
        test_subscribe();
        assertTrue(assetRegistry.getSubscription(ASSET_ID) > block.timestamp);
    }

    function test_getSubscriptionPrice() public {
        test_createAsset();
        address asset = assetRegistry.getAsset(ASSET_ID);
        assertEq(assetRegistry.getSubscriptionPrice(ASSET_ID, 10), IAsset(asset).getSubscriptionPrice(10));
    }

    function test_updateFeeShare() public {
        assetRegistry.updateCreatorFeeShare(80);
        assetRegistry.updateRegistryFeeShare(20);
        assertEq(assetRegistry.getCreatorFee(100000000), 80000000);
        assertEq(assetRegistry.getRegistryFee(100000000), 20000000);
    }

    function test_feeSplit() public {
        uint256 registryBalance = gameToken.balanceOf(assetRegistry.getOwner());
        uint256 creatorBalance = gameToken.balanceOf(signer);
        
        test_subscribe();

        uint256 value = SUBSCRIPTION_PRICE * DURATION;

        uint256 creatorFee = assetRegistry.getCreatorFee(value);
        uint256 registryFee = assetRegistry.getRegistryFee(value);

        assertEq(gameToken.balanceOf(signer) - creatorBalance, creatorFee);
        assertEq(gameToken.balanceOf(assetRegistry.getOwner()) - registryBalance, registryFee);
    }
}