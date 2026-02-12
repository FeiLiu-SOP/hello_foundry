// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title SimpleWallet - 一个简单的钱包合约
 * @notice 这个合约演示了权限控制，只有 owner 可以提取资金
 */
contract SimpleWallet {
    // 钱包的所有者地址
    address public owner;
    
    // 钱包的余额
    uint256 public balance;
    
    // 事件：记录谁提取了多少钱
    event Withdraw(address indexed caller, uint256 amount);
    
    /**
     * @notice 构造函数，设置合约的所有者
     * @param _owner 钱包的所有者地址
     */
    constructor(address _owner) {
        owner = _owner;
    }
    
    /**
     * @notice 接收以太币的函数
     */
    receive() external payable {
        balance += msg.value;
    }
    
    /**
     * @notice 提取资金 - 只有 owner 可以调用
     * @param amount 要提取的金额
     */
    function withdraw(uint256 amount) public {
        // 权限检查：只有 owner 可以提取
        require(msg.sender == owner, "Only owner can withdraw!");
        
        // 检查余额是否足够
        require(balance >= amount, "Insufficient balance!");
        
        // 更新余额
        balance -= amount;
        
        // 转账给调用者
        payable(msg.sender).transfer(amount);
        
        // 发出事件
        emit Withdraw(msg.sender, amount);
    }
    
    /**
     * @notice 获取当前余额
     */
    function getBalance() public view returns (uint256) {
        return balance;
    }
}
