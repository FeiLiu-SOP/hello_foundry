# TimeLock Vault

基于 Foundry 的 ETH 时间锁金库：存入 ETH，到期后由 owner 提取。

## 功能

- `lock()`：默认锁仓 30 天
- `lockFor(duration)`：自定义锁仓时长
- `withdraw()`：仅 owner 在到期后可提取
- 事件：`Locked`、`Withdrawn`

## Sepolia 部署（已验证）

| 项 | 值 |
|----|-----|
| 网络 | Sepolia (Chain ID: 11155111) |
| 合约地址 | [`0x1E7693220b1eba6f73D9df606A20ff4a1aB02142`](https://sepolia.etherscan.io/address/0x1E7693220b1eba6f73D9df606A20ff4a1aB02142) |
| Owner | `0xdBBb0437E38DFE967B8140AEe472281cFf7cB6E7` |
| 源码 | Etherscan 已 Verify |

## 本地开发

```bash
# 编译
forge build

# 跑全部测试
forge test

# 看时间锁测试日志
forge test --match-test test_Warp_TimeJump -vvv
```

## 部署到 Sepolia

```bash
# 1. 模拟（不花 Gas）
forge script script/DeployTimeLock.s.sol \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com

# 2. 真部署
forge script script/DeployTimeLock.s.sol \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --broadcast \
  --private-key $PRIVATE_KEY
```

## 项目结构

```text
src/TimeLock.sol          核心合约
test/TimeLock.t.sol       测试（含 vm.warp / prank / expectRevert）
script/DeployTimeLock.s.sol  部署脚本
```

## 链下索引（项目 B）

Go 服务读取本合约 `Locked` 事件：[`../chain-indexer`](../chain-indexer)

```bash
cd ../chain-indexer
go mod tidy
go run .
```

## 技术栈

- Solidity 0.8.x
- Foundry (forge / cast)
- Sepolia Testnet
