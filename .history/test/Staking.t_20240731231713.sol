// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {DeployStaking} from "../script/DeployStaking.s.sol";
import {Staking} from "../src/Staking.sol";

contract StakingTest is Test{

    Staking staker;
    function setUp () public{
        DeployStaking deploy = new DeployStaking();
        (staker,,) = deploy.run();
    }

}