// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {Staking} from "../src/Staking.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DeployStaking is Script {
    function run() public returns(Staking,) {
        ERC20Mock tkn = new ERC20Mock();
        ERC20Mock weth = new ERC20Mock();
        vm.startBroadcast();
        Staking staking = new Staking(address(tkn), address(weth));
        vm.stopBroadcast();
        return staking;
    }

}