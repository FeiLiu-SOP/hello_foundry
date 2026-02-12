// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title TimeLock - 一个简单的锁仓合约
 * @notice 演示时间相关的功能，用于学习 vm.warp 和 vm.roll
 */
contract TimeLock {
    // 锁仓的金额
    uint256 public lockedAmount;
    
    // 锁仓的到期时间（时间戳）
    uint256 public unlockTime;
    
    // 锁仓的用户地址
    address public owner;
    
    // 事件：记录锁仓和提取
    event Locked(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);
    
    /**
     * @notice 构造函数
     * @param _owner 锁仓的用户地址
     */
    constructor(address _owner) {
        owner = _owner;
    }
    
    /**
     * @notice 锁仓函数 - 锁定资金 30 天
     * @dev 用户调用这个函数，资金会被锁定 30 天
     */
    function lock() external payable {
        require(msg.value > 0, "Must send some ETH");
        require(lockedAmount == 0, "Already locked");
        
        // 记录锁仓金额
        lockedAmount = msg.value;
        
        // 设置解锁时间：当前时间 + 30 天
        // 30 天 = 30 * 24 * 60 * 60 = 2,592,000 秒
        unlockTime = block.timestamp + 30 days;
        
        emit Locked(msg.sender, msg.value, unlockTime);
    }
    
    /**
     * @notice 提取函数 - 只有在锁仓到期后才能提取
     * @dev 检查当前时间是否已经超过解锁时间
     */
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(lockedAmount > 0, "No funds locked");
        require(block.timestamp >= unlockTime, "Still locked! Wait until unlock time");
        
        // 记录要提取的金额
        uint256 amount = lockedAmount;
        
        // 清零
        lockedAmount = 0;
        unlockTime = 0;
        
        // 转账给用户
        payable(owner).transfer(amount);
        
        emit Withdrawn(owner, amount);
    }
    
    /**
     * @notice 获取当前区块时间
     */
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }
    
    /**
     * @notice 获取当前区块号
     */
    function getCurrentBlock() external view returns (uint256) {
        return block.number;
    }
    
    /**
     * @notice 检查是否可以提取
     */
    function canWithdraw() external view returns (bool) {
        return block.timestamp >= unlockTime && lockedAmount > 0;
    }
}
