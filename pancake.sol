// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract lottery {

    uint256 round;
    uint256 price = 0.01 ether;
    uint256 winning_price = 0.01 ether;

    mapping (uint256 => mapping (address => uint256[])) my_numbers;
    mapping (uint256 => uint256[]) win_numbers;

    function lottery_in(uint256[] memory numbers) public payable {
        require(msg.value == price);
        my_numbers[round][msg.sender] = numbers;
    }

    function lottart_set(uint256[] memory numbers) public{
        win_numbers[round] = numbers;
        round = round +1;
    }

    function check_round_number() public view returns(uint256){
        return round;
    }

    function claim(uint256 this_round) public {
        // emptys
    }
    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function compare(uint256[] memory numbers1, uint256[] memory numbers2) public pure returns (bool) {
        return keccak256(abi.encodePacked(numbers1)) == keccak256(abi.encodePacked(numbers2));
    }
}