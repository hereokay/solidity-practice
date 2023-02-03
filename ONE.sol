// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is ERC20 {
    constructor() ERC20("Lottery", "ONE") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}