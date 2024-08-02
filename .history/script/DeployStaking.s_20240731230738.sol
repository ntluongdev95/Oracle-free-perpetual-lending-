// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {Staking} from "../src/Staking.sol";

contract DeployStaking is Script {
    function run() public returns(Staking) {
        vm.startBroadcast();
        Staking lender = new Staking();
        vm.stopBroadcast();
        return lender;
    }

}