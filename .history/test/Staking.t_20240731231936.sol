// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {DeployStaking} from "../script/DeployStaking.s.sol";
import {Staking} from "../src/Staking.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract StakingTest is Test{

    Staking staker;
    ERC20Mock tkn;
    ERC20Mock weth;

    address public admin = makeAddr("admin");
    address public user = makeAddr("user");
    address public user2 = makeAddr("user2");


    function setUp () public{
        DeployStaking deploy = new DeployStaking();
        (staker,tkn,weth) = deploy.run();
    }

}