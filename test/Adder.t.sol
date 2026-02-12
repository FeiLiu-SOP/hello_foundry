// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Adder} from "../src/Adder.sol";

/**
 * @title AdderTest - 用最简单的例子学习 Fuzzing（模糊测试）
 *
 * 对应你截图里的三个步骤：
 * 1. 写 Property（性质）: 比如 “无论怎么换，结果不会变小”、“a + b == b + a”等。
 * 2. 运行 fuzz：让 Foundry 自动随机跑很多组 (a, b)。
 * 3. 看结果：如果有一组失败，Foundry 会告诉你具体的参数。
 *
 * 类比 Java：
 * - 普通单测：assertEquals(add(1, 2), 3);
 * - Fuzz 测试：给 add(a, b) 扔成千上万组随机的 a、b，自动帮你找边界情况。
 */
contract AdderTest is Test {
    Adder public adder;

    function setUp() public {
        adder = new Adder();
    }

    /**
     * @notice 普通示例测试：只测一组固定数据
     * @dev 类似 Java 里的 assertEquals(add(1, 2), 3)
     */
    function test_Add_SimpleExample() public {
        uint256 result = adder.add(1, 2);
        assertEq(result, 3, "1 + 2 should be 3");
    }

    /**
     * @notice Fuzz 示例1：函数返回值 == 期望的数学结果
     *
     * @dev 这是最入门的 Fuzz 测试：
     *      - Foundry 会自动为 a、b 生成很多随机 uint256
     *      - 我们写的 Property（性质）是：adder.add(a, b) == a + b
     *
     * 名字以 testFuzz_ 开头，Foundry 会自动当成 Fuzz 测试：
     *   forge test --match-test testFuzz_Add_EqualsMath -vv
     */
    function testFuzz_Add_EqualsMath(uint256 a, uint256 b) public {
        // 这里直接用 a + b，注意可能溢出：
        // - Solidity 0.8 会在溢出时 revert
        // - 为了避免输入导致的 revert，我们做一个假设限制（assume）

        // 假设：a + b 不会溢出（a <= max - b）
        vm.assume(a <= type(uint256).max - b);

        uint256 result = adder.add(a, b);
        uint256 expected = a + b;

        assertEq(result, expected, "add(a, b) should equal a + b");
    }

    /**
     * @notice Fuzz 示例2：交换参数顺序，结果应该一样（加法交换律）
     *
     * Property（性质）：
     *   对所有的 a, b，都应该满足：add(a, b) == add(b, a)
     */
    function testFuzz_Add_Commutative(uint256 a, uint256 b) public {
        // 同样先做一个简单的溢出假设，避免无意义的 revert
        vm.assume(a <= type(uint256).max - b);
        vm.assume(b <= type(uint256).max - a);

        uint256 result1 = adder.add(a, b);
        uint256 result2 = adder.add(b, a);

        assertEq(result1, result2, "add should be commutative: a + b == b + a");
    }

    /**
     * @notice Fuzz 示例3：结果不小于任意一个输入（单调性）
     *
     * Property（性质）：
     *   对所有的 a, b，都应该满足：
     *     add(a, b) >= a
     *     add(a, b) >= b
     */
    function testFuzz_Add_NotLessThanInputs(uint256 a, uint256 b) public {
        // 仍然先限制一下，避免溢出
        vm.assume(a <= type(uint256).max - b);

        uint256 result = adder.add(a, b);

        assertGe(result, a, "a + b should be >= a");
        assertGe(result, b, "a + b should be >= b");
    }
}

