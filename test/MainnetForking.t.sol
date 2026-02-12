// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IUniswapV2Router} from "../src/interfaces/IUniswapV2Router.sol";

/**
 * @title MainnetForkingTest - 演示主网分叉的用法
 * @notice 用最简单的方式学习如何 fork 主网并与真实协议交互
 */
contract MainnetForkingTest is Test {
    // ========== 主网上的真实合约地址 ==========
    // 这些是 Ethereum 主网上真实存在的合约地址
    
    // USDC 代币地址（主网）
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    // Uniswap V2 Router 地址（主网）
    address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    // WETH 地址（主网）
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    // USDC 大户地址（主网上拥有大量 USDC 的地址）
    // 这个地址在主网上有大量的 USDC，我们可以"借用"一些用于测试
    address constant USDC_WHALE = 0xDa9CE944a37d218c3302F6B82a094844C6ECEb17;
    
    // 测试账号（我们自己）
    address public testUser = address(0x123);
    
    // 代币接口
    IERC20 public usdc;
    IUniswapV2Router public router;
    
    /**
     * @notice 测试前的准备工作
     * @dev 这里会 fork 主网，创建本地的主网环境
     * 
     * ⚠️ 重要：运行这些测试需要提供 fork-url
     * 命令：forge test --fork-url YOUR_RPC_URL --match-path test/MainnetForking.t.sol -vvv
     * 
     * 获取 RPC URL：
     * 1. Alchemy: https://www.alchemy.com/ (推荐，免费)
     * 2. Infura: https://www.infura.io/ (免费)
     * 3. 公共 RPC: https://eth.llamarpc.com (不推荐，可能不稳定)
     */
    function setUp() public {
        // ========== 核心：Fork 主网 ==========
        // vm.createSelectFork 的作用：把整个以太坊主网"克隆"到本地
        // 你的本地环境瞬间拥有了 Uniswap, Aave, Curve 的所有真实合约和数据
        // ==========================================
        
        // ⚠️ 注意：这个测试需要通过命令行提供 fork-url
        // 如果没有提供，测试会失败
        // 
        // 运行方式：
        // forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY --match-path test/MainnetForking.t.sol -vvv
        
        // 初始化接口
        usdc = IERC20(USDC);
        router = IUniswapV2Router(UNISWAP_V2_ROUTER);
        
        // 如果 fork 成功，block.number 应该 > 0
        // 如果没有 fork，block.number 会是 0
        if (block.number == 0) {
            // Use only ASCII in logs to avoid Solidity unicode string issues
            console.log("WARNING: no fork detected");
            console.log("Run: forge test --fork-url YOUR_RPC_URL --match-path test/MainnetForking.t.sol -vvv");
            console.log("Get RPC URL from: https://www.alchemy.com or https://www.infura.io");
        } else {
            console.log("Fork mainnet OK");
            console.log("block number:", block.number);
            console.log("block timestamp:", block.timestamp);
        }
    }
    
    /**
     * @notice 测试1：检查 fork 是否成功
     * @dev 验证我们是否真的 fork 了主网
     */
    function test_CheckFork() public {
        // ========== 验证 Fork 是否成功 ==========
        // 如果 fork 成功，我们应该能够访问主网上的真实合约
        // ==========================================
        
        // 检查 USDC 的总供应量（主网上的真实数据）
        uint256 totalSupply = usdc.totalSupply();
        console.log("USDC totalSupply:", totalSupply);
        
        // 检查 USDC 大户的余额（主网上的真实数据）
        uint256 whaleBalance = usdc.balanceOf(USDC_WHALE);
        console.log("USDC whale balance (raw):", whaleBalance);
        console.log("USDC whale balance (formatted):", whaleBalance / 1e6, "USDC");
        
        // 验证：大户应该有大量的 USDC
        assertGt(whaleBalance, 0, "Whale should have USDC");
        
        console.log("Fork success: can read mainnet data");
    }
    
    /**
     * @notice 测试2：给测试账号"印"100万 USDC
     * @dev 这是核心！在 fork 环境中，我们可以"借用"大户的代币
     */
    function test_MintUSDC_ToTestAccount() public {
        // ========== 在本地（分叉环境）给你的测试账号印 100 万 USDC ==========
        // 这是 0 成本的、真实的金融模拟演习
        // ==========================================
        
        uint256 amount = 1_000_000 * 1e6;  // 100 万 USDC（USDC 有 6 位小数）
        
        console.log("Start minting USDC in fork env");
        console.log("Target account:", testUser);
        console.log("Target amount:", amount / 1e6, "USDC");
        
        // 方法：从大户地址转账到我们的测试账号
        // 在 fork 环境中，我们可以模拟任何地址的行为
        vm.prank(USDC_WHALE);  // "夺舍"：让下一行代码的调用者变成大户
        usdc.transfer(testUser, amount);  // 大户转账给我们的测试账号
        
        // 验证：测试账号现在应该有 100 万 USDC
        uint256 balance = usdc.balanceOf(testUser);
        console.log("Test account USDC balance:", balance / 1e6, "USDC");
        
        assertEq(balance, amount, "Test account should have 1M USDC");
        
        console.log("Mint 1M USDC success");
    }
    
    /**
     * @notice 测试3：在本地调用真实的 Uniswap Router 换成 ETH
     * @dev 这是完整的交易流程：USDC -> ETH
     */
    function test_UniswapSwap_USDCToETH() public {
        // ========== 在本地调用真实的 Uniswap Router 换成 ETH ==========
        // 这是 0 成本的、真实的金融模拟演习
        // ==========================================
        
        // 步骤1：先给测试账号"印"一些 USDC
        uint256 usdcAmount = 10_000 * 1e6;  // 1 万 USDC
        vm.prank(USDC_WHALE);
        usdc.transfer(testUser, usdcAmount);
        
        console.log("Start Uniswap swap USDC -> ETH");
        console.log("Before swap - USDC balance:", usdc.balanceOf(testUser) / 1e6, "USDC");
        console.log("Before swap - ETH balance:", address(testUser).balance / 1e18, "ETH");
        
        // 步骤2：授权 Uniswap Router 使用我们的 USDC
        vm.prank(testUser);
        usdc.approve(UNISWAP_V2_ROUTER, usdcAmount);
        
        // 步骤3：查询兑换率（可以换多少 ETH）
        address[] memory path = new address[](2);
        path[0] = USDC;   // 从 USDC 开始
        path[1] = WETH;   // 换成 WETH（Wrapped ETH）
        
        uint256[] memory amountsOut = router.getAmountsOut(usdcAmount, path);
        uint256 expectedETH = amountsOut[1];
        
        console.log("Expected ETH out:", expectedETH / 1e18, "ETH");
        
        // 步骤4：执行兑换（USDC -> ETH）
        vm.prank(testUser);
        router.swapExactTokensForETH(
            usdcAmount,                    // 输入的 USDC 数量
            0,                             // 最小输出的 ETH 数量（0 表示接受任何价格）
            path,                          // 兑换路径：USDC -> WETH
            testUser,                      // 接收 ETH 的地址
            block.timestamp + 300          // 交易截止时间（5 分钟后）
        );
        
        // 步骤5：验证兑换结果
        uint256 usdcBalanceAfter = usdc.balanceOf(testUser);
        uint256 ethBalanceAfter = address(testUser).balance;
        
        console.log("Swap done");
        console.log("After swap - USDC balance:", usdcBalanceAfter / 1e6, "USDC");
        console.log("After swap - ETH balance:", ethBalanceAfter / 1e18, "ETH");
        console.log("Received ETH:", ethBalanceAfter / 1e18, "ETH");
        
        // 验证：USDC 应该减少了
        assertLt(usdcBalanceAfter, usdcAmount, "USDC should decrease");
        
        // 验证：ETH 应该增加了
        assertGt(ethBalanceAfter, 0, "Should receive ETH");
        
        console.log("Uniswap swap in fork env success");
    }
    
    /**
     * @notice 测试4：完整的套利机器人场景
     * @dev 演示如何测试一个基于 Uniswap 的套利机器人
     */
    function test_ArbitrageBot_Scenario() public {
        // ========== 场景：测试套利机器人 ==========
        // 公司让你写一个"基于 Uniswap 的套利机器人合约"
        // 你怎么测？去主网测要花真钱
        // 使用 Fork，可以在本地 0 成本测试！
        // ==========================================
        
        console.log("Arbitrage bot test scenario");
        
        // 步骤1：给机器人"印"一些启动资金
        uint256 initialUSDC = 50_000 * 1e6;  // 5 万 USDC
        vm.prank(USDC_WHALE);
        usdc.transfer(testUser, initialUSDC);
        
        console.log("Bot initial USDC:", initialUSDC / 1e6, "USDC");
        
        // 步骤2：查询价格
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = WETH;
        
        uint256[] memory amountsOut = router.getAmountsOut(initialUSDC, path);
        uint256 expectedETH = amountsOut[1];
        
        console.log("Current price 1 USDC in ETH (approx):", (expectedETH * 1e6) / initialUSDC / 1e12, "ETH");
        
        // 步骤3：执行兑换（模拟套利操作）
        vm.startPrank(testUser);
        usdc.approve(UNISWAP_V2_ROUTER, initialUSDC);
        router.swapExactTokensForETH(
            initialUSDC,
            0,
            path,
            testUser,
            block.timestamp + 300
        );
        vm.stopPrank();
        
        // 步骤4：验证结果
        uint256 finalETH = address(testUser).balance;
        console.log("ETH gained after arbitrage:", finalETH / 1e18, "ETH");
        
        assertGt(finalETH, 0, "Should have ETH after arbitrage");
        
        console.log("Arbitrage bot test finished");
    }
}
