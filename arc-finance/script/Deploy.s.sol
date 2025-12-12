// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ArcFinance.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ArcFinance arcFinance = new ArcFinance();
        
        console.log("ArcFinance deployed to:", address(arcFinance));

        vm.stopBroadcast();
    }
}
