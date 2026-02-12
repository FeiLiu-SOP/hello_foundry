# vm.warp 和 vm.roll 使用教程

## 📖 核心概念

### vm.warp(timestamp) - 时间跳跃

**含义**："时间跳跃"。把区块时间调到未来（或过去）。

**作用**：修改 `block.timestamp`（当前区块的时间戳）

**场景**：测试质押锁仓 30 天。你不用等 30 天，直接 warp 过去！

### vm.roll(blockNumber) - 修改区块号

**含义**：修改区块号。

**作用**：修改 `block.number`（当前区块号）

**场景**：测试依赖区块号的逻辑，比如每 100 个区块执行一次操作。

## 🎯 最简单的例子

### 例子1：vm.warp - 时间跳跃

```solidity
// 场景：锁仓 30 天，测试提取功能

// 步骤1：锁仓
timeLock.lock{value: 10 ether}();

// 步骤2：尝试提取（应该失败，因为还没到 30 天）
vm.expectRevert("Still locked!");
timeLock.withdraw();

// 步骤3：使用 vm.warp 跳到 30 天后
vm.warp(block.timestamp + 30 days);  // 🚀 时间跳跃！不用等 30 天！

// 步骤4：现在可以提取了！
timeLock.withdraw();  // ✅ 成功！
```

### 例子2：vm.roll - 修改区块号

```solidity
// 记录初始区块号
uint256 startBlock = block.number;  // 假设是 100

// 使用 vm.roll 跳到区块 1000
vm.roll(1000);

// 现在 block.number 就是 1000 了
assertEq(block.number, 1000);  // ✅
```

## 🔍 两者的区别

| 特性 | vm.warp | vm.roll |
|------|---------|---------|
| 修改什么 | `block.timestamp`（时间） | `block.number`（区块号） |
| 不影响 | `block.number` | `block.timestamp` |
| 常用场景 | 测试时间锁、质押解锁 | 测试区块号相关的逻辑 |

### 对比示例

```solidity
uint256 startTime = block.timestamp;  // 假设是 1000
uint256 startBlock = block.number;    // 假设是 100

// 使用 vm.warp
vm.warp(startTime + 1 days);
// block.timestamp = 1000 + 86400 ✅ 改变了
// block.number = 100 ❌ 没改变

// 使用 vm.roll
vm.roll(startBlock + 100);
// block.timestamp = 1000 + 86400 ❌ 没改变
// block.number = 200 ✅ 改变了
```

## 📝 实际使用场景

### 场景1：测试锁仓 30 天

```solidity
function test_30DayLock() public {
    // 1. 锁仓
    timeLock.lock{value: 10 ether}();
    
    // 2. 验证：还不能提取
    assertEq(timeLock.canWithdraw(), false);
    
    // 3. 时间跳跃到 30 天后
    vm.warp(block.timestamp + 30 days);
    
    // 4. 验证：现在可以提取了
    assertEq(timeLock.canWithdraw(), true);
    
    // 5. 提取
    timeLock.withdraw();
}
```

### 场景2：测试时间相关的奖励

```solidity
function test_DailyReward() public {
    // 第一天领取奖励
    claimReward();
    
    // 跳到第二天
    vm.warp(block.timestamp + 1 days);
    
    // 第二天领取奖励
    claimReward();
}
```

### 场景3：测试区块号相关的逻辑

```solidity
function test_Every100Blocks() public {
    // 当前是区块 100
    doSomething();
    
    // 跳到区块 200
    vm.roll(200);
    
    // 现在可以执行每 100 个区块的操作了
    doSomething();
}
```

## 🚀 如何运行测试

### 运行所有时间相关的测试

```bash
forge test --match-path test/TimeLock.t.sol -vvv
```

### 运行单个测试

```bash
# 测试时间跳跃
forge test --match-test test_Warp_TimeJump -vvv

# 测试区块号修改
forge test --match-test test_Roll_ChangeBlockNumber -vvv

# 测试实际场景
forge test --match-test test_RealScenario_30DayLock -vvv
```

## 💡 关键理解

### 1. vm.warp 只改变时间，不改变区块号

```solidity
vm.warp(block.timestamp + 1 days);
// block.timestamp ✅ 改变了
// block.number ❌ 没改变
```

### 2. vm.roll 只改变区块号，不改变时间

```solidity
vm.roll(block.number + 100);
// block.number ✅ 改变了
// block.timestamp ❌ 没改变
```

### 3. 可以连续使用

```solidity
vm.warp(block.timestamp + 30 days);  // 跳到 30 天后
vm.roll(block.number + 100);         // 跳到区块号 + 100
```

### 4. 可以跳到过去（虽然不常用）

```solidity
vm.warp(block.timestamp - 1 days);  // 跳到 1 天前
```

## 📚 时间单位

Solidity 提供了一些时间单位：

```solidity
1 seconds  // 1 秒
1 minutes  // 1 分钟 = 60 秒
1 hours    // 1 小时 = 3600 秒
1 days     // 1 天 = 86400 秒
1 weeks    // 1 周 = 604800 秒
```

### 使用示例

```solidity
vm.warp(block.timestamp + 1 days);      // 1 天后
vm.warp(block.timestamp + 30 days);     // 30 天后
vm.warp(block.timestamp + 1 weeks);     // 1 周后
vm.warp(block.timestamp + 365 days);    // 1 年后
```

## ⚠️ 注意事项

1. **vm.warp 只影响时间，不影响区块号**
2. **vm.roll 只影响区块号，不影响时间**
3. **时间戳是秒级精度**（不是毫秒）
4. **可以跳到过去，但通常用于跳到未来**

## 🎓 学习路径

### 第一步：理解基本概念
- 阅读 `test/TimeLock.t.sol` 中的注释
- 理解 `vm.warp` 如何改变时间
- 理解 `vm.roll` 如何改变区块号

### 第二步：运行测试
- 运行测试，观察每个测试的行为
- 查看 console.log 的输出

### 第三步：自己动手
- 创建一个新的时间相关的合约
- 编写测试，使用 `vm.warp` 测试不同的时间场景

## ✅ 总结

- ✅ **vm.warp(timestamp)** - 时间跳跃，修改 `block.timestamp`
- ✅ **vm.roll(blockNumber)** - 修改区块号，修改 `block.number`
- ✅ **两者互不影响** - warp 不影响区块号，roll 不影响时间
- ✅ **常用场景** - 测试锁仓、质押、时间相关的奖励等
