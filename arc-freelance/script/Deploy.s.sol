// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ArcFreelance.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ArcFreelance arcFreelance = new ArcFreelance();
        
        console.log("ArcFreelance deployed to:", address(arcFreelance));

        vm.stopBroadcast();
    }
}
