// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Swap {
    uint public x = 1;
    uint public y = 2;
    function swap() public {
        uint z = y;
        y = x;
        x = z;
    }
}

// swap 2 variables with destructuring assignment
contract DesSwap {
    uint public x = 1;
    uint public y = 2;
    function swap() public {
        (x, y) = (y, x);
    }
}

// swap 2 variables with bit operation
contract BitOperationSwap {
    uint public x = 1;
    uint public y = 2;
    function swap() public {
        uint _x = x | y;
        y = _x | y;
        x = _x | y;
    }
}

contract SwapVarsTest {
    Swap public swap;
    DesSwap public desSwap;
    BitOperationSwap public bitOperationSwap;

    function setUp() public {
        swap = new Swap();
        desSwap = new DesSwap();
        bitOperationSwap = new BitOperationSwap();
    }

    function testSwap() public {
        swap.swap();
    }

    function testDesSwap() public {
        desSwap.swap();
    }

    function testBitOperationSwap() public {
        bitOperationSwap.swap();
    }
}
