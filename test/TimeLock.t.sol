// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TimeLock} from "../src/TimeLock.sol";

/**
 * @title TimeLockTest - 演示 vm.warp 和 vm.roll 的用法
 * @notice 用最简单的方式学习时间跳跃和区块号修改
 */
contract TimeLockTest is Test {
    TimeLock public timeLock;
    address public owner;

    function setUp() public {
        owner = makeAddr("owner");
        timeLock = new TimeLock(owner);
        
        // 给测试合约一些 ETH，用于锁仓
        vm.deal(address(this), 100 ether);
    }
    
    /**
     * @notice 测试1：正常锁仓（不使用 warp）
     * @dev 演示基本的锁仓功能
     */
    function test_LockFunds() public {
        // 锁仓 10 ETH
        timeLock.lock{value: 10 ether}();
        
        // 验证锁仓金额
        assertEq(timeLock.lockedAmount(), 10 ether, "Should lock 10 ETH");
        
        // 验证解锁时间（应该是当前时间 + 30 天）
        uint256 expectedUnlockTime = block.timestamp + 30 days;
        assertEq(timeLock.unlockTime(), expectedUnlockTime, "Unlock time should be 30 days from now");
    }
    
    /**
     * @notice 测试2：演示 vm.warp - 时间跳跃
     * @dev 这是核心！vm.warp 可以"时间跳跃"，不用等 30 天
     */
    function test_Warp_TimeJump() public {
        // ========== vm.warp 的核心用法 ==========
        // vm.warp(timestamp) 的含义："时间跳跃"
        // 作用：把区块时间调到未来（或过去）
        // ==========================================
        
        // 步骤1：先锁仓 10 ETH
        timeLock.lock{value: 10 ether}();
        
        // 记录锁仓时间
        uint256 lockTime = block.timestamp;
        console.log("lock time:", lockTime);
        console.log("unlock time:", timeLock.unlockTime());
        
        // 步骤2：尝试提取（应该失败，因为还没到 30 天）
        vm.expectRevert("Still locked! Wait until unlock time");
        vm.prank(owner);
        timeLock.withdraw();
        
        // 步骤3：使用 vm.warp 跳跃到未来（30 天后）
        // 注意：30 天 = 30 * 24 * 60 * 60 = 2,592,000 秒
        uint256 futureTime = lockTime + 30 days + 1 seconds;  // 30 天 + 1 秒后
        vm.warp(futureTime);  // 🚀 时间跳跃！不用等 30 天！
        
        console.log("time after warp:", block.timestamp);
        console.log("unlock time:", timeLock.unlockTime());
        
        // 步骤4：现在可以提取了！（因为时间已经过了 30 天）
        vm.prank(owner);
        timeLock.withdraw();
        
        // 验证：锁仓金额应该清零
        assertEq(timeLock.lockedAmount(), 0, "Locked amount should be 0 after withdrawal");
    }
    
    /**
     * @notice 测试3：演示 vm.warp 可以跳到任意时间
     * @dev 可以跳到未来，也可以跳到过去
     */
    function test_Warp_JumpToAnyTime() public {
        // 记录初始时间
        uint256 startTime = block.timestamp;
        console.log("start time:", startTime);
        
        // 跳跃到 1 小时后
        vm.warp(startTime + 1 hours);
        console.log("after 1 hour:", block.timestamp);
        assertEq(block.timestamp, startTime + 1 hours, "Should be 1 hour later");
        
        // 跳跃到 1 天后
        vm.warp(startTime + 1 days);
        console.log("after 1 day:", block.timestamp);
        assertEq(block.timestamp, startTime + 1 days, "Should be 1 day later");
        
        // 跳跃到 1 年后
        vm.warp(startTime + 365 days);
        console.log("after 1 year:", block.timestamp);
        assertEq(block.timestamp, startTime + 365 days, "Should be 1 year later");
        
        // 甚至可以跳到过去（虽然不常用）
        vm.warp(startTime - 1 days);
        console.log("1 day before:", block.timestamp);
        assertEq(block.timestamp, startTime - 1 days, "Should be 1 day earlier");
    }
    
    /**
     * @notice 测试4：演示 vm.roll - 修改区块号
     * @dev vm.roll 可以修改区块号（block.number）
     */
    function test_Roll_ChangeBlockNumber() public {
        // ========== vm.roll 的核心用法 ==========
        // vm.roll(blockNumber) 的含义：修改区块号
        // 作用：把当前区块号改成指定的值
        // ==========================================
        
        // 记录初始区块号
        uint256 startBlock = block.number;
        console.log("start block:", startBlock);
        
        // 使用 vm.roll 跳到区块 1000
        vm.roll(1000);
        console.log("block after roll:", block.number);
        assertEq(block.number, 1000, "Block number should be 1000");
        
        // 跳到区块 10000
        vm.roll(10000);
        console.log("block after roll:", block.number);
        assertEq(block.number, 10000, "Block number should be 10000");
        
        // 跳到区块 999999
        vm.roll(999999);
        console.log("block after roll:", block.number);
        assertEq(block.number, 999999, "Block number should be 999999");
    }
    
    /**
     * @notice 测试5：warp 和 roll 的区别
     * @dev 理解两者的区别很重要
     */
    function test_WarpVsRoll_Difference() public {
        uint256 startTime = block.timestamp;
        uint256 startBlock = block.number;
        
        console.log("=== initial state ===");
        console.log("timestamp:", startTime);
        console.log("block number:", startBlock);
        
        // vm.warp 只改变时间，不改变区块号
        vm.warp(startTime + 1 days);
        console.log("\n=== use vm.warp(time + 1 day) ===");
        console.log("timestamp:", block.timestamp);  // changed
        console.log("block number:", block.number);  // unchanged
        
        assertEq(block.timestamp, startTime + 1 days, "Time should change");
        assertEq(block.number, startBlock, "Block number should NOT change");
        
        // vm.roll 只改变区块号，不改变时间
        vm.roll(startBlock + 100);
        console.log("\n=== use vm.roll(block + 100) ===");
        console.log("timestamp:", block.timestamp);  // unchanged
        console.log("block number:", block.number);  // changed
        
        assertEq(block.timestamp, startTime + 1 days, "Time should NOT change");
        assertEq(block.number, startBlock + 100, "Block number should change");
    }
    
    /**
     * @notice 测试6：实际场景 - 测试锁仓 30 天
     * @dev 完整的测试流程：锁仓 -> 等待（用 warp）-> 提取
     */
    function test_RealScenario_30DayLock() public {
        // 步骤1：锁仓 50 ETH
        uint256 lockAmount = 50 ether;
        timeLock.lock{value: lockAmount}();
        
        uint256 lockTime = block.timestamp;
        uint256 unlockTime = timeLock.unlockTime();
        
        console.log("=== lock phase ===");
        console.log("lock amount:", lockAmount);
        console.log("lock time:", lockTime);
        console.log("unlock time:", unlockTime);
        console.log("need wait (seconds):", unlockTime - lockTime);
        
        // 验证：还不能提取
        assertEq(timeLock.canWithdraw(), false, "Should not be able to withdraw yet");
        
        // 步骤2：使用 vm.warp 跳到 30 天后
        // 不用真的等 30 天！直接 warp 过去！
        vm.warp(unlockTime + 1 seconds);  // 跳到解锁时间 + 1 秒
        
        console.log("\n=== 30 days later (warp) ===");
        console.log("current time:", block.timestamp);
        console.log("unlock time:", unlockTime);
        
        // 验证：现在可以提取了
        assertEq(timeLock.canWithdraw(), true, "Should be able to withdraw now");
        
        // 步骤3：提取资金
        uint256 balanceBefore = address(owner).balance;
        vm.prank(owner);
        timeLock.withdraw();
        uint256 balanceAfter = address(owner).balance;
        
        console.log("\n=== withdraw success ===");
        console.log("balance before:", balanceBefore);
        console.log("balance after:", balanceAfter);
        console.log("withdraw amount:", balanceAfter - balanceBefore);
        
        // 验证：提取成功
        assertEq(balanceAfter - balanceBefore, lockAmount, "Should withdraw locked amount");
        assertEq(timeLock.lockedAmount(), 0, "Locked amount should be 0");
    }
}
