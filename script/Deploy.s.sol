// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployScript is Script {
    /// @notice Generic deployment function that deploys any contract
    /// @param contractName The contract artifact path, e.g., "src/Counter.sol:Counter"
    /// @param constructorArgs ABI-encoded constructor arguments (use abi.encode(...))
    /// @return deployedAddress The address of the deployed contract
    function deployContract(string memory contractName, bytes memory constructorArgs)
        public
        returns (address deployedAddress)
    {
        if (constructorArgs.length == 0) {
            deployedAddress = deployCode(contractName);
        } else {
            deployedAddress = deployCode(contractName, constructorArgs);
        }
        
        require(deployedAddress != address(0), "Deployment failed");
        
        return deployedAddress;
    }

    /// @notice Deploy a contract with constructor arguments from command line
    /// @param contractName The contract artifact path, e.g., "src/Counter.sol:Counter"
    /// @param constructorArgs ABI-encoded constructor arguments as hex string (0x...)
    /// @return deployedAddress The address of the deployed contract
    /// 
    /// Usage example:
    /// forge script script/Deploy.s.sol:DeployScript \
    ///   "src/Counter.sol:Counter" "0x000000000000000000000000000000000000000000000000000000000000002a" \
    ///   --sig "run(string,bytes)" \
    ///   --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
    function run(string memory contractName, bytes memory constructorArgs) public returns (address deployedAddress) {
        vm.startBroadcast();
        
        deployedAddress = deployContract(contractName, constructorArgs);

        vm.stopBroadcast();

        return deployedAddress;
    }
}