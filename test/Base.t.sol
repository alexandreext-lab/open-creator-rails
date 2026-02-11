// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {GameToken} from "../src/GameToken.sol";
import {IAsset} from "../src/IAsset.sol";
import {Asset} from "../src/Asset.sol";
import {IAssetRegistry} from "../src/IAssetRegistry.sol";
import {AssetRegistry} from "../src/AssetRegistry.sol";

contract BaseTest is Test {

    GameToken internal gameToken;
    IAsset internal asset;
    IAssetRegistry internal assetRegistry;


    bytes32 internal constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    string internal constant MNEMONIC = "test test test test test test test test test test test junk";

    bytes32 internal constant ASSET_ID = keccak256(abi.encodePacked("asset_id"));
    uint256 internal constant SUBSCRIPTION_PRICE = 100000000;
    uint256 internal constant DURATION = 3600;

    address internal ASSET_OWNER;
    address internal REGISTRY_OWNER;

    address internal signer;
    uint256 internal key;

    function setUp() public virtual {
        gameToken = new GameToken();

        key = vm.deriveKey(MNEMONIC, 0);
        signer = vm.addr(key);

        vm.startPrank(signer);

        gameToken.mint(signer, 1000000000000000000000000000000000000000);

        REGISTRY_OWNER = address(1);
        ASSET_OWNER = address(2);

        vm.startPrank(REGISTRY_OWNER);
        assetRegistry = new AssetRegistry(70, 30);
        asset = IAsset(assetRegistry.createAsset(ASSET_ID, SUBSCRIPTION_PRICE, address(gameToken), ASSET_OWNER));
        vm.stopPrank();
    }

    function getPermit(address owner, address spender, uint256 value, uint256 deadline) public view returns (uint8 v, bytes32 r, bytes32 s) {
        
        uint256 nonce = gameToken.nonces(owner);

        bytes32 hash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", gameToken.DOMAIN_SEPARATOR(), hash)
        );

        (v, r, s) = vm.sign(key, digest);

        return (v, r, s);
    }
}