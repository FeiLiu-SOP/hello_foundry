# Mainnet Forking 设置指南

## 🎯 快速开始

### 步骤1：获取 RPC URL

你需要一个 Ethereum 主网的 RPC 端点。推荐使用 **Alchemy**（免费）：

1. 访问：https://www.alchemy.com/
2. 注册账号（免费）
3. 点击 "Create App"
4. 选择 "Ethereum" 和 "Mainnet"
5. 复制 HTTP URL（格式：`https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY`）


### 步骤2：运行测试

```bash
# 替换 YOUR_API_KEY 为你的实际 API Key
forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY --match-path test/MainnetForking.t.sol -vvv
```

### 步骤3：查看结果

测试会显示：
- ✅ Fork 是否成功
- ✅ 可以访问主网上的真实数据
- ✅ "印"代币的过程
- ✅ Uniswap 兑换的结果

## 📝 详细设置

### 方法1：使用命令行参数（最简单）

```bash
forge test --fork-url YOUR_RPC_URL --match-path test/MainnetForking.t.sol -vvv
```

### 方法2：使用环境变量

```bash
# 1. 设置环境变量
export MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY

# 2. 运行测试
forge test --fork-url $MAINNET_RPC_URL --match-path test/MainnetForking.t.sol -vvv
```

### 方法3：在代码中直接指定（不推荐）

```solidity
function setUp() public {
    vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY");
}
```

## 🔍 测试用例

### 测试1：检查 Fork

```bash
forge test --fork-url YOUR_RPC_URL --match-test test_CheckFork -vvv
```

**验证**：Fork 是否成功，能否访问主网数据。

### 测试2："印"USDC

```bash
forge test --fork-url YOUR_RPC_URL --match-test test_MintUSDC_ToTestAccount -vvv
```

**验证**：能否从大户地址"借用"代币。

### 测试3：Uniswap 兑换

```bash
forge test --fork-url YOUR_RPC_URL --match-test test_UniswapSwap_USDCToETH -vvv
```

**验证**：能否在本地调用真实的 Uniswap。

### 测试4：套利机器人场景

```bash
forge test --fork-url YOUR_RPC_URL --match-test test_ArbitrageBot_Scenario -vvv
```

**验证**：完整的套利机器人测试场景。

## ⚠️ 常见问题

### 问题1：找不到 RPC URL

**错误**：`Error: Failed to fork`

**解决**：
1. 检查 RPC URL 是否正确
2. 检查 API Key 是否有效
3. 尝试使用其他 RPC 提供商

### 问题2：网络超时

**错误**：`Error: Request timeout`

**解决**：
1. 检查网络连接
2. 尝试使用其他 RPC 提供商
3. 增加超时时间

### 问题3：余额不足

**错误**：`Error: Insufficient balance`

**解决**：
1. 确保使用正确的大户地址
2. 检查 fork 的区块号（某些区块可能没有足够的余额）

## 💡 提示

1. **使用自己的 API Key**：免费额度足够测试使用
2. **缓存数据**：第一次运行会下载数据，后续运行会使用缓存
3. **Fork 特定区块**：可以 fork 特定区块的状态
4. **测试隔离**：每个测试都会重新 fork，状态完全隔离

## 📚 相关资源

- [Foundry 文档 - Forking](https://book.getfoundry.sh/forge/fork-testing)
- [Alchemy](https://www.alchemy.com/)
- [Infura](https://www.infura.io/)
