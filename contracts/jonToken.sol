// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "solmate/src/tokens/ERC20.sol";

contract jonStaking is ERC20("jonStaking", "JST", 18) {
    constructor(address user) {
        _mint(user, 100000e18);
    }
}