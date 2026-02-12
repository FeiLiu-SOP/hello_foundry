// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title IUniswapV2Router - Uniswap V2 Router 接口
 * @notice 用于在 fork 环境中与真实的 Uniswap 交互
 */
interface IUniswapV2Router {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getAmountsOut(uint amountIn, address[] calldata path)
        external view returns (uint[] memory amounts);
}
