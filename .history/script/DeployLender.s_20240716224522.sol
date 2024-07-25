// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {Lender} from "../src/Lender.sol";

contract Deploy is Script {

    function run() public returns(Lender) {
        vm.startBroadcast();
        Lender lender = new Lender();
        vm.stopBroadcast();
        return lender;
    }

}