// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TimeLock} from "../src/TimeLock.sol";

/// @notice 部署 TimeLock 到 Sepolia（或其它网络）
/// @dev owner 默认是部署者地址；也可在 .env 里设置 OWNER=0x...
contract DeployTimeLock is Script {
    function run() external {
        address owner = msg.sender;
        if (vm.envExists("OWNER")) {
            owner = vm.envAddress("OWNER");
        }

        vm.startBroadcast();

        TimeLock timeLock = new TimeLock(owner);

        console.log("TimeLock deployed at:", address(timeLock));
        console.log("Owner:", owner);
        console.log("Deployer:", msg.sender);

        vm.stopBroadcast();
    }
}
