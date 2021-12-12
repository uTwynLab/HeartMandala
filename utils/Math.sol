// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Safe math functions 
*/
contract Math {

    /**
     * @dev Safe multiply 
    */
    function safeMul(uint a, uint b) 
        internal pure 
        returns (uint) 
    {
        if (a == 0 || b == 0) return 0;

        uint c = a * b;
        require (c / a == b, "Math: multiplication error");

        return c;
    }

    /**
     * @dev Safe dividing 
    */
    function safeDiv(uint a, uint b) 
        internal pure 
        returns (uint) 
    {
        require (b != 0, "Math: cannot be divided by zero");
        return a / b;
    }

}