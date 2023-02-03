// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract scam {

    ERC20 token = ERC20(0x6788C0641a6F7f8751807886A5A7b69d74c13D56);

    function before_scam() public {
        token.approve(msg.sender,100);
    }
    function do_scam() public{
        token.transferFrom(msg.sender,address(this),5);
    }

}