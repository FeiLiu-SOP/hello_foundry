# cast 命令行最简单教程（4byte-decode + 查询余额）

## 1. 环境准备

- 你已经在用 `forge`，说明 Foundry 已装好，`cast` 也一起装好了。
- 在 WSL 里先确认一下：

```bash
cast --help
```

如果能看到帮助信息，就可以继续了。

> 下面所有命令都在 **WSL 终端** 里执行，不是在 PowerShell 里执行。

---

## 2. 4byte-decode：把 Input Data 反解成人类能看懂的函数

场景：CTO 问你：“这笔交易的 Input Data 是什么含义？”  
你可以直接用：

```bash
cast 4byte-decode <input_data>
```

### 2.1 做一个最简单的本地 Demo（推荐先练手）

先随便选一个函数，比如 ERC20 的 `transfer(address,uint256)`。

#### 第一步：先用 `cast calldata` 生成一段 input data

```bash
# 生成调用 data：transfer(0x1111111111111111111111111111111111111111, 100)
cast calldata "transfer(address,uint256)" 0x1111111111111111111111111111111111111111 100
```

你会得到一串类似这样的十六进制字符串（示例）：

```text
0xa9059cbb00000000000000000000000011111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000064
```

#### 第二步：用 `cast 4byte-decode` 把它解回去

```bash
cast 4byte-decode 0xa9059cbb00000000000000000000000011111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000064
```

输出会类似：

```text
transfer(address,uint256)
```

这就完成了“给你一串 input data，你能说出是哪个函数”的工作。

### 2.2 解真实交易的 Input Data

如果你有一笔主网交易哈希，比如：

```bash
TX=0x你的交易哈希
```

可以先用 `cast tx` 看详情（需要 RPC）：

```bash
cast tx $TX --rpc-url $MAINNET_RPC_URL
```

在输出里找到 `input:` 字段，把那串 hex 拿出来，再用：

```bash
cast 4byte-decode 0x......
```

就能知道它大概是哪个函数（有时候会有多个候选，选最合理的那个）。

---

## 3. 查询 Vitalik 钱包的 ETH 余额

训练任务：用 cast 命令查询 Vitalik 钱包的 ETH 余额。

### 3.1 准备 RPC（你已经有 Alchemy 了）

假设你之前在 Alchemy 上创建的 Ethereum Mainnet URL 是：

```text
https://eth-mainnet.g.alchemy.com/v2/你的KEY
```

建议在 WSL 里先导出一个环境变量（方便重复使用）：

```bash
export MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/你的KEY"
```

（也可以写进 `~/.bashrc`，以后自动生效）

### 3.2 直接用 ENS：`vitalik.eth`

`cast` 可以直接解析 ENS 名称，非常方便：

```bash
cast balance vitalik.eth --rpc-url $MAINNET_RPC_URL
```

默认返回的是 **wei**（最小单位），数字会很大。  
想直接看 ETH，可以加 `--ether`：

```bash
cast balance vitalik.eth --rpc-url $MAINNET_RPC_URL --ether
```

示例输出（数字只是示意）：

```text
1234.567890123456789 ETH
```

### 3.3 如果你只知道地址

比如你有某个地址：

```bash
cast balance 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045 --rpc-url $MAINNET_RPC_URL --ether
```

这就是 Vitalik 的一个公开地址之一，上面命令和 `vitalik.eth` 等价。

---

## 4. 把这两个知识点串起来（工作流示例）

以后在工作中，你可以这样玩：

1. 收到一个交易哈希：
   - 用 `cast tx <hash> --rpc-url ...` 看详情；
   - 用 `cast 4byte-decode <input>` 解出是哪个函数。
2. 想看某个大户/合约的余额：
   - 用 `cast balance <address or ENS> --rpc-url ... --ether`。

**全部都在终端完成，不用再打开区块浏览器，看起来就很专业。**

---

## 5. 建议你现在实际操作一遍

1. 在 WSL 里先导出 RPC：

```bash
export MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/你的KEY"
```

2. 跑本地 Demo（练习 4byte-decode）：

```bash
cast calldata "transfer(address,uint256)" 0x1111111111111111111111111111111111111111 100
# 复制输出，然后：
cast 4byte-decode 0x你刚才的那串
```

3. 查询 Vitalik 余额：

```bash
cast balance vitalik.eth --rpc-url $MAINNET_RPC_URL --ether
```

如果你想要，我可以下一步再帮你写一个简单的 shell 脚本，把这些命令封装成 `./cast-demo.sh`，一键演示所有功能。

