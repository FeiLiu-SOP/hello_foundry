# Mainnet Forking（主网分叉）使用教程

## 📖 什么是 Mainnet Forking？

**Mainnet Forking** 是 Foundry 的一个强大功能，允许你把整个以太坊主网"克隆"到本地进行测试。

### 核心概念

- **Fork（分叉）**：复制主网的当前状态到本地
- **真实合约**：可以访问主网上所有真实的合约（Uniswap、Aave、Curve 等）
- **真实数据**：使用主网上的真实数据（价格、余额等）
- **0 成本**：不需要花费真实的 ETH 或 gas

### 为什么需要 Fork？

**场景**：公司让你写一个"基于 Uniswap 的套利机器人合约"。你怎么测？

- ❌ **去主网测**：要花真钱，每次测试都要付 gas
- ✅ **Fork 主网**：0 成本，可以无限次测试

## 🎯 核心功能

### 1. Fork 主网

```solidity
// 在 setUp() 中 fork 主网
vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY");
```

**效果**：你的本地环境瞬间拥有了 Uniswap, Aave, Curve 的所有真实合约和数据。

### 2. "印"代币（给测试账号）

```solidity
// 从大户地址"借用"一些代币
vm.prank(USDC_WHALE);  // 模拟大户
usdc.transfer(testUser, 1_000_000 * 1e6);  // 转账 100 万 USDC
```

**效果**：在本地（分叉环境）给你的测试账号印 100 万 USDC。

### 3. 调用真实协议

```solidity
// 在本地调用真实的 Uniswap Router 换成 ETH
router.swapExactTokensForETH(
    usdcAmount,
    0,
    path,
    testUser,
    block.timestamp + 300
);
```

**效果**：这是 0 成本的、真实的金融模拟演习。

## 🚀 如何运行测试

### 方法1：使用命令行参数（推荐）

```bash
# 使用你自己的 RPC URL
forge test --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY --match-path test/MainnetForking.t.sol -vvv
```

### 方法2：使用环境变量

```bash
# 1. 创建 .env 文件
echo "MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY" > .env

# 2. 运行测试
forge test --fork-url $MAINNET_RPC_URL --match-path test/MainnetForking.t.sol -vvv
```

### 方法3：在代码中直接指定（不推荐，硬编码）

```solidity
function setUp() public {
    vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY");
}
```

## 📝 详细步骤

### 步骤1：获取 RPC URL

你需要一个 Ethereum 主网的 RPC 端点：

1. **Alchemy**（推荐）：
   - 访问：https://www.alchemy.com/
   - 注册账号（免费）
   - 创建应用，选择 Ethereum Mainnet
   - 复制 HTTP URL

2. **Infura**：
   - 访问：https://www.infura.io/
   - 注册账号（免费）
   - 创建项目，选择 Ethereum Mainnet
   - 复制 HTTPS URL

3. **公共 RPC**（不推荐，可能不稳定）：
   - `https://eth.llamarpc.com`
   - `https://rpc.ankr.com/eth`

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

## 🔍 测试用例说明

### 测试1：`test_CheckFork()`

**目的**：验证 Fork 是否成功

**检查**：
- USDC 的总供应量（主网真实数据）
- USDC 大户的余额（主网真实数据）

### 测试2：`test_MintUSDC_ToTestAccount()`

**目的**：演示如何"印"代币

**步骤**：
1. 使用 `vm.prank` 模拟大户
2. 从大户地址转账到测试账号
3. 验证测试账号的余额

### 测试3：`test_UniswapSwap_USDCToETH()`

**目的**：演示如何在本地调用真实的 Uniswap

**步骤**：
1. "印"一些 USDC
2. 授权 Uniswap Router
3. 查询兑换率
4. 执行兑换（USDC -> ETH）
5. 验证结果

### 测试4：`test_ArbitrageBot_Scenario()`

**目的**：完整的套利机器人场景

**演示**：如何测试一个基于 Uniswap 的套利机器人，0 成本，真实环境。

## 💡 关键理解

### 1. Fork 是"快照"，不是实时同步

- Fork 会复制主网在某个区块的状态
- 之后的操作只在本地进行，不影响主网
- 可以 fork 不同的区块号

### 2. "印"代币的原理

```solidity
// 在 fork 环境中，我们可以模拟任何地址的行为
vm.prank(USDC_WHALE);  // 模拟大户
usdc.transfer(testUser, amount);  // 大户转账给测试账号
```

**注意**：这只是 fork 环境中的操作，不会影响主网。

### 3. 可以调用真实协议

- Uniswap Router 是主网上的真实合约
- 在 fork 环境中调用，使用的是主网的真实逻辑
- 但不会花费真实的 gas 或代币

### 4. 0 成本测试

- 不需要真实的 ETH
- 不需要真实的代币
- 可以无限次测试
- 完全模拟真实环境

## 🎓 实际应用场景

### 场景1：测试套利机器人

```solidity
function test_ArbitrageBot() public {
    // 1. Fork 主网
    vm.createSelectFork("...");
    
    // 2. "印"启动资金
    vm.prank(USDC_WHALE);
    usdc.transfer(bot, 100_000 * 1e6);
    
    // 3. 执行套利逻辑
    bot.executeArbitrage();
    
    // 4. 验证利润
    assertGt(bot.profit(), 0);
}
```

### 场景2：测试 DeFi 协议集成

```solidity
function test_IntegrateWithAave() public {
    // Fork 主网，访问真实的 Aave 合约
    vm.createSelectFork("...");
    
    // 测试与 Aave 的交互
    aave.deposit(...);
    aave.borrow(...);
}
```

### 场景3：测试价格预言机

```solidity
function test_PriceOracle() public {
    // Fork 主网，使用真实的价格数据
    vm.createSelectFork("...");
    
    // 测试价格查询
    uint256 price = oracle.getPrice(USDC);
    assertGt(price, 0);
}
```

## ⚠️ 注意事项

### 1. 需要 RPC 端点

- 必须提供有效的 RPC URL
- 建议使用自己的 API Key（免费额度足够测试）
- 公共 RPC 可能不稳定

### 2. Fork 的区块号

```solidity
// Fork 特定区块
vm.createSelectFork("...", 18000000);  // Fork 区块 18000000 的状态
```

### 3. 网络延迟

- Fork 需要从 RPC 获取数据，可能有延迟
- 第一次运行会较慢（需要下载数据）
- 后续运行会使用缓存，更快

### 4. 只读操作

- Fork 环境中的操作不会影响主网
- 可以安全地测试各种场景
- 包括攻击场景（如闪电贷攻击）

## 📚 学习路径

### 第一步：理解基本概念
- 阅读 `test/MainnetForking.t.sol` 中的注释
- 理解 Fork 的作用和原理

### 第二步：获取 RPC URL
- 注册 Alchemy 或 Infura 账号
- 获取免费的 RPC URL

### 第三步：运行测试
- 使用 `--fork-url` 参数运行测试
- 观察每个测试的行为

### 第四步：自己动手
- 创建一个新的测试场景
- 尝试与其他协议交互（如 Aave、Curve）

## ✅ 总结

- ✅ **Mainnet Forking** = 把主网"克隆"到本地
- ✅ **真实合约** = 可以访问 Uniswap、Aave、Curve 等
- ✅ **"印"代币** = 从大户地址转账到测试账号
- ✅ **0 成本** = 不需要真实的 ETH 或代币
- ✅ **真实环境** = 完全模拟主网环境

## 🔗 相关资源

- [Foundry 文档 - Forking](https://book.getfoundry.sh/forge/fork-testing)
- [Alchemy](https://www.alchemy.com/)
- [Infura](https://www.infura.io/)
- [Uniswap V2 文档](https://docs.uniswap.org/contracts/v2/overview)
