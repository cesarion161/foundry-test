// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/DomainRegister.sol"; // Update the path according to your project structure

contract DeployDomainRegister is Script {
    function run() external {
        vm.startBroadcast();
        DomainRegister domainRegister = new DomainRegister();
        console.log("DomainRegister deployed to:", address(domainRegister));
        vm.stopBroadcast();
    }
}