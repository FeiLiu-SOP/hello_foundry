// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title Adder - 一个最简单的加法合约
 * @notice 用来配合 Fuzzing（模糊测试）学习
 *
 * Java 里的方法大概就是：
 *   int add(int a, int b) { return a + b; }
 *
 * 这里我们用 Solidity 写一个类似的函数。
 */
contract Adder {
    /**
     * @notice 计算 a + b
     * @dev 纯函数（pure），不读不写状态，只做数学运算
     */
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        // Solidity 0.8 以后，uint256 加法会自动检查溢出（overflow），
        // 如果超过最大值，会 revert。
        return a + b;
    }
}

