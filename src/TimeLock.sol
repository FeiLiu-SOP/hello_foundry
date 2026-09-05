// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title TimeLock - 时间锁金库
 * @notice 存入 ETH，到期后 owner 可提取；支持自定义锁仓时长
 */
contract TimeLock {
    uint256 public lockedAmount;
    uint256 public unlockTime;
    uint256 public lockDuration;
    address public owner;

    event Locked(address indexed user, uint256 amount, uint256 duration, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);
    
    /**
     * @notice 构造函数
     * @param _owner 锁仓的用户地址
     */
    constructor(address _owner) {
        owner = _owner;
    }
    
    /// @notice 锁仓 30 天（默认）
    function lock() external payable {
        lockFor(30 days);
    }

    /// @notice 自定义锁仓时长，例如 7 days、30 days
    function lockFor(uint256 duration) public payable {
        require(msg.value > 0, "Must send some ETH");
        require(lockedAmount == 0, "Already locked");
        require(duration > 0, "Duration must be > 0");

        lockedAmount = msg.value;
        lockDuration = duration;
        unlockTime = block.timestamp + duration;

        emit Locked(msg.sender, msg.value, duration, unlockTime);
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
        
        lockedAmount = 0;
        unlockTime = 0;
        lockDuration = 0;
        
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
