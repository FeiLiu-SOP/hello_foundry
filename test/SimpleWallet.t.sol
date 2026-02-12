// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleWallet} from "../src/SimpleWallet.sol";

/**
 * @title SimpleWalletTest - 演示 vm.prank 的用法
 * @notice 这个测试文件展示了如何使用 Foundry 的 vm.prank 来模拟不同的调用者
 */
contract SimpleWalletTest is Test {
    SimpleWallet public wallet;
    
    // 创建几个测试地址
    address public owner = address(0x1);        // 钱包所有者
    address public hacker = address(0x999);     // 模拟黑客地址
    address public whale = address(0x888);      // 模拟大户地址（拥有1亿美金）
    
    /**
     * @notice 测试前的准备工作
     * @dev setUp 函数会在每个测试函数运行前自动执行
     */
    function setUp() public {
        // 创建钱包，设置 owner
        wallet = new SimpleWallet(owner);
        
        // 给钱包充值 100 ETH
        // 注意：vm.deal() 只给地址分配 ETH，不会触发 receive() 函数
        // 所以需要实际转账来触发 receive()，更新合约的 balance 变量
        vm.deal(address(this), 100 ether);  // 先给测试合约一些 ETH
        
        // 使用 call 转账，更安全，会触发 receive() 函数
        (bool success, ) = address(wallet).call{value: 100 ether}("");
        require(success, "Transfer to wallet failed");
    }
    
    /**
     * @notice 测试1：正常情况 - owner 提取资金（不使用 prank）
     * @dev 这是正常流程，owner 自己调用 withdraw
     */
    function test_NormalWithdraw_OwnerCanWithdraw() public {
        // 记录测试前的余额
        uint256 balanceBefore = wallet.getBalance();
        assertEq(balanceBefore, 100 ether, "Wallet should have 100 ETH");
        
        // owner 直接调用 withdraw（不需要 prank，因为测试函数默认的调用者就是 owner）
        // 但是我们需要先切换到 owner 地址
        vm.prank(owner);
        wallet.withdraw(50 ether);
        
        // 验证余额减少了
        assertEq(wallet.getBalance(), 50 ether, "Balance should be 50 ETH after withdrawal");
    }
    
    /**
     * @notice 测试2：使用 vm.prank 模拟 owner 提取资金
     * @dev 演示 vm.prank 的基本用法：让下一行代码的调用者变成 owner
     */
    function test_Prank_SimulateOwner() public {
        // ========== vm.prank 的核心用法 ==========
        // vm.prank(address) 的含义："夺舍"
        // 作用：让下一行代码的调用者（msg.sender）变成指定的地址
        // ==========================================
        
        // 使用 vm.prank(owner) 后，下一行代码的 msg.sender 就会变成 owner
        vm.prank(owner);
        wallet.withdraw(30 ether);
        
        // 验证提取成功
        assertEq(wallet.getBalance(), 70 ether, "Balance should be 70 ETH");
    }
    
    /**
     * @notice 测试3：模拟黑客尝试提取资金（应该失败）
     * @dev 演示如何使用 vm.prank 模拟黑客攻击，但应该被权限检查阻止
     */
    function test_Prank_SimulateHacker_ShouldFail() public {
        // ========== 场景：模拟黑客攻击 ==========
        // 黑客想要提取资金，但应该被 require(msg.sender == owner) 阻止
        // ==========================================
        
        // 使用 vm.prank 让下一行代码的调用者变成 hacker
        vm.prank(hacker);
        
        // 尝试提取资金，但应该失败（因为 hacker 不是 owner）
        // vm.expectRevert 表示我们期望下一行代码会 revert
        vm.expectRevert("Only owner can withdraw!");
        wallet.withdraw(50 ether);
        
        // 验证余额没有变化（因为提取失败了）
        assertEq(wallet.getBalance(), 100 ether, "Balance should still be 100 ETH");
    }
    
    /**
     * @notice 测试4：模拟大户（whale）尝试提取资金（应该失败）
     * @dev 演示如何使用 vm.prank 模拟大户，但同样应该被权限检查阻止
     */
    function test_Prank_SimulateWhale_ShouldFail() public {
        // ========== 场景：模拟拥有1亿美金的大户 ==========
        // 即使是大户，如果不是 owner，也不能提取资金
        // ==========================================
        
        // 给大户地址一些 ETH（虽然这不会影响权限检查）
        vm.deal(whale, 1_000_000_000 ether); // 10亿 ETH，模拟大户
        
        // 使用 vm.prank 让下一行代码的调用者变成 whale
        vm.prank(whale);
        
        // 尝试提取资金，但应该失败（因为 whale 不是 owner）
        vm.expectRevert("Only owner can withdraw!");
        wallet.withdraw(50 ether);
        
        // 验证余额没有变化
        assertEq(wallet.getBalance(), 100 ether, "Balance should still be 100 ETH");
    }
    
    /**
     * @notice 测试5：演示 vm.prank 只影响下一行代码
     * @dev 重要：vm.prank 只影响紧跟着它的下一行代码
     */
    function test_Prank_OnlyAffectsNextLine() public {
        // 第一次调用：使用 prank 模拟 owner
        vm.prank(owner);
        wallet.withdraw(20 ether);
        
        // 注意：prank 的效果已经结束了，现在调用者又变回了测试合约本身
        
        // 第二次调用：不使用 prank，直接调用会失败（因为测试合约不是 owner）
        vm.expectRevert("Only owner can withdraw!");
        wallet.withdraw(20 ether);
        
        // 验证第一次提取成功了
        assertEq(wallet.getBalance(), 80 ether, "Balance should be 80 ETH");
    }
    
    /**
     * @notice 测试6：连续使用多个 prank
     * @dev 演示如何连续模拟不同的调用者
     */
    function test_Prank_MultiplePranks() public {
        // 第一次：owner 提取 10 ETH
        vm.prank(owner);
        wallet.withdraw(10 ether);
        assertEq(wallet.getBalance(), 90 ether, "First withdrawal successful");
        
        // 第二次：再次使用 prank 让 owner 提取 20 ETH
        vm.prank(owner);
        wallet.withdraw(20 ether);
        assertEq(wallet.getBalance(), 70 ether, "Second withdrawal successful");
        
        // 第三次：尝试让 hacker 提取（应该失败）
        vm.prank(hacker);
        vm.expectRevert("Only owner can withdraw!");
        wallet.withdraw(10 ether);
        
        // 验证余额没有变化
        assertEq(wallet.getBalance(), 70 ether, "Balance unchanged after failed attempt");
    }
    
    /**
     * @notice 测试7：对比 - 不使用 prank 的情况
     * @dev 演示如果不使用 prank，调用者就是测试合约本身
     */
    function test_WithoutPrank_TestContractIsCaller() public {
        // 不使用 prank，直接调用 withdraw
        // 此时 msg.sender 是测试合约（SimpleWalletTest）的地址
        // 因为测试合约不是 owner，所以应该失败
        vm.expectRevert("Only owner can withdraw!");
        wallet.withdraw(50 ether);
    }
}
