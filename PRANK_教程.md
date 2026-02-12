# vm.prank(address) 使用教程

## 📖 什么是 vm.prank？

`vm.prank(address)` 是 Foundry 测试框架中的一个"作弊码"（cheatcode），它的作用是：

**"夺舍"** - 让下一行代码的调用者（`msg.sender`）变成指定的地址

## 🎯 核心概念

### 基本语法
```solidity
vm.prank(address);  // 让下一行代码的调用者变成这个地址
下一行代码();        // 这行代码的 msg.sender 就是上面指定的地址
```

### 重要特点
1. **只影响下一行代码**：`vm.prank` 的效果只持续到下一行代码执行完
2. **模拟任何地址**：可以模拟任何地址，包括黑客、大户、普通用户等
3. **测试权限控制**：非常适合测试合约的权限检查逻辑

## 📝 实际例子

### 例子1：模拟 owner 提取资金

```solidity
// 场景：钱包只有 owner 可以提取资金
// 使用 prank 模拟 owner 来提取

vm.prank(owner);           // "夺舍"：下一行代码的调用者变成 owner
wallet.withdraw(50 ether);  // 这行代码的 msg.sender 是 owner，可以成功提取
```

### 例子2：模拟黑客攻击（应该失败）

```solidity
// 场景：黑客尝试提取资金，但应该被权限检查阻止

vm.prank(hacker);          // "夺舍"：下一行代码的调用者变成 hacker
vm.expectRevert("Only owner can withdraw!");  // 期望下一行代码会失败
wallet.withdraw(50 ether); // 这行代码的 msg.sender 是 hacker，应该失败
```

### 例子3：模拟大户（whale）

```solidity
// 场景：模拟拥有1亿美金的大户尝试操作

vm.deal(whale, 1_000_000_000 ether);  // 给大户一些 ETH
vm.prank(whale);                       // "夺舍"：下一行代码的调用者变成 whale
// 然后可以测试大户的各种操作...
```

## 🚀 如何运行测试

### 基础命令

1. **运行所有测试**：
   ```bash
   forge test
   ```

2. **只运行 SimpleWallet 的测试文件**：
   ```bash
   forge test --match-path test/SimpleWallet.t.sol
   ```

3. **只运行单个测试用例**（最常用，最精准）：
   ```bash
   # 只运行 test_Prank_SimulateHacker_ShouldFail 这一个测试
   forge test --match-test test_Prank_SimulateHacker_ShouldFail
   
   # 只运行 test_Prank_SimulateOwner 这一个测试
   forge test --match-test test_Prank_SimulateOwner
   ```

4. **查看详细输出**：
   ```bash
   forge test --match-test test_Prank_SimulateHacker_ShouldFail -vvv
   ```

### 💡 开发建议

- **写测试时**：只运行当前测试，快速迭代
  ```bash
  forge test --match-test test_你的测试名 -vvv
  ```
  
- **测试通过后**：运行所有相关测试
  ```bash
  forge test --match-path test/SimpleWallet.t.sol
  ```
  
- **提交前**：运行所有测试
  ```bash
  forge test
  ```

## 📚 学习路径

### 第一步：理解基本概念
- 阅读 `test/SimpleWallet.t.sol` 中的注释
- 理解 `vm.prank` 如何改变 `msg.sender`

### 第二步：运行测试
- 运行测试，观察每个测试的行为
- 尝试修改测试，看看会发生什么

### 第三步：自己动手
- 创建一个新的合约，包含权限检查
- 编写测试，使用 `vm.prank` 测试不同的场景

## 🔍 测试文件说明

### `src/SimpleWallet.sol`
- 一个简单的钱包合约
- 只有 owner 可以提取资金
- 用于演示权限控制

### `test/SimpleWallet.t.sol`
包含 7 个测试用例，演示了：
1. ✅ 正常提取（owner）
2. ✅ 使用 prank 模拟 owner
3. ✅ 模拟黑客攻击（应该失败）
4. ✅ 模拟大户（应该失败）
5. ✅ prank 只影响下一行代码
6. ✅ 连续使用多个 prank
7. ✅ 不使用 prank 的情况

## 💡 常见使用场景

1. **测试权限控制**：模拟不同权限的用户尝试操作
2. **测试攻击场景**：模拟黑客尝试攻击合约
3. **测试边界情况**：模拟特殊地址（如零地址、合约地址等）
4. **测试多用户交互**：模拟多个用户之间的交互

## ⚠️ 注意事项

1. `vm.prank` 只影响**下一行代码**
2. 如果需要持续影响多行代码，需要使用 `vm.startPrank()` 和 `vm.stopPrank()`
3. 在测试中，默认的 `msg.sender` 是测试合约本身
4. 使用 `vm.expectRevert()` 来测试应该失败的场景

## 🎓 下一步学习

- `vm.startPrank()` / `vm.stopPrank()` - 持续影响多行代码
- `vm.deal()` - 给地址分配 ETH
- `vm.warp()` - 修改区块时间
- `vm.roll()` - 修改区块号
- 更多 Foundry cheatcodes...
