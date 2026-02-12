# Mainnet Forking 快速参考

## 🚀 基本用法

### Fork 主网

```solidity
// 在 setUp() 中
vm.createSelectFork("YOUR_RPC_URL");
```

### 运行测试

```bash
forge test --fork-url YOUR_RPC_URL --match-path test/MainnetForking.t.sol -vvv
```

## 📋 主网合约地址

```solidity
// USDC
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

// Uniswap V2 Router
address constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

// WETH
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

// USDC 大户（用于"印"代币）
address constant USDC_WHALE = 0xDa9CE944a37d218c3302F6B82a094844C6ECEb17;
```

## 💰 "印"代币

```solidity
// 从大户地址转账到测试账号
vm.prank(USDC_WHALE);
usdc.transfer(testUser, 1_000_000 * 1e6);  // 100 万 USDC
```

## 🔄 Uniswap 兑换

```solidity
// 1. 授权
usdc.approve(UNISWAP_V2_ROUTER, amount);

// 2. 设置路径
address[] memory path = new address[](2);
path[0] = USDC;
path[1] = WETH;

// 3. 执行兑换
router.swapExactTokensForETH(
    amount,
    0,
    path,
    to,
    block.timestamp + 300
);
```

## 🎯 核心要点

1. **Fork = 克隆主网状态**
2. **"印"代币 = 从大户转账**
3. **0 成本 = 不需要真实 ETH**
4. **真实环境 = 使用真实合约和数据**

## 📝 常用命令

```bash
# 运行所有 fork 测试
forge test --fork-url YOUR_RPC_URL

# 运行单个测试
forge test --fork-url YOUR_RPC_URL --match-test test_UniswapSwap_USDCToETH -vvv

# 使用环境变量
forge test --fork-url $MAINNET_RPC_URL
```
