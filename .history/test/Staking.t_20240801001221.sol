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
        tkn.mint(user,1000*10**18);
        tkn.mint(user2,1000*10**18);
        weth.mint(admin,1000*10**18);
    }

    function test_deposit() public{
        vm.startPrank(user);
        tkn.approve(address(staker),100*10**18);
        staker.deposit(100*10**18);
        vm.stopPrank();
        assertEq(staker.balances(user),100*10**18);
        console.log(staker.supplyIndex(user));
        console.log(staker.index());
    }

    function test_rewardsNoTokenStaked() public {
        //transfer 10 weth with no token staked
        vm.startPrank(admin);
        weth.approve(address(staker),10 ether);
        weth.transfer(address(staker),10 ether);
        vm.startPrank(user);
        tkn.approve(address(staker),20*10**18);
        staker.deposit(20*10**18);
        console.log(staker.supplyIndex(user));
        console.log(staker.index());

         // claim the weth rewards
        vm.startPrank(user);
        staker.claim();

assertEq(weth.balanceOf(address(staker)) / 1 ether, 10);
assertEq(weth.balanceOf(address(user)) / 1 ether, 0);

        // the first 10 weth are forever stuck on the contract
 console.log(weth.balanceOf(address(stakerg)) / 1 ether);
weth.balanceOf(staker1)/ 1 ether);

    }

    

}