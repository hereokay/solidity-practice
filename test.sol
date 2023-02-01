// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract lottary {

    mapping (address => uint256) users;
    uint256 win_number;
    uint256 win_reward;
    address owner;
    mapping (uint256 => uint256) count;
    
    constructor(){
        owner = msg.sender;
    }

    function lottary_in(uint256 number) public payable {
        require(msg.value == 0.001 ether);
        require(number != users[msg.sender]);

        users[msg.sender] = number;
        count[number] = count[number] + 1;
    }

    function lottart_set(uint256 number) public {
        require(msg.sender == owner);
        win_number = number;
    }

    function claim() public {
        require(win_number == users[msg.sender]);

        win_reward = address(this).balance / count[win_number];

        count[win_number] = count[win_number] - 1;
        users[msg.sender] = 0 ;
        address payable to = payable(msg.sender);
        to.transfer(win_reward);
    }

    function print_reward() public view returns(uint256){
        return address(this).balance / count[win_number];
    }

    function print_count() public view returns(uint256){
        return count[win_number];
    }

}