// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract VRFD20 is VRFConsumerBaseV2 {
    uint256 private constant ROLL_IN_PROGRESS = 42;

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Goerli coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 s_keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    
    uint32 callbackGasLimit = 40000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;
    address s_owner;

    // map rollers to requestIds
    mapping(uint256 => address) private s_rollers;
    // map vrf results to rollers
    mapping(address => uint256) private s_results;

    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function rollDice() public returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_rollers[requestId] = s_owner;
        s_results[s_owner] = ROLL_IN_PROGRESS;
        emit DiceRolled(requestId, s_owner);
    }

    
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 d20Value = (randomWords[0] % 3) + 1;
        s_results[s_rollers[requestId]] = d20Value;
        emit DiceLanded(requestId, d20Value);
    }


    function getRandomNumber() public view returns (uint256) {
        require(s_results[s_owner] != 0, "Dice not rolled");
        require(s_results[s_owner] != ROLL_IN_PROGRESS, "Roll in progress");

        return s_results[s_owner];
    }


    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is ERC20, Ownable {

    mapping (uint256 => mapping (address => uint256[2])) table; // 0 : 번호, 양
    mapping (uint256 => uint256) win_number;
    uint256 round;
        // Goerli coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    bytes32 s_keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;


    
    constructor() ERC20("Lottery", "ONE") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function lottary_in(uint256 number) public payable {
        require(msg.value >= 0.000000001 ether,"to pay more than 1 Gwei");
        table[round][msg.sender][0] = number;
        table[round][msg.sender][1] = msg.value;
    }


    function lottart_set(VRFD20 _callee) onlyOwner public {        
        win_number[round] = _callee.getRandomNumber();
        round = round + 1;
    }

    function claim(uint target_round, uint number) public {
        require(table[target_round][msg.sender][0] == number);
        require(win_number[round]==number);

        uint256 reward = table[target_round][msg.sender][1] * 3;
        transfer(msg.sender,reward);
    }


    function token2eth(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount);
        
        // 토큰을 전송받기 위한 approve
        approve(msg.sender, amount);
        
        // 실제 토큰 전송
        transferFrom(msg.sender,address(this),amount);

        // ether를 1대1 만큼 전송해준다.
        address payable to = payable(msg.sender); 
        to.transfer(amount); 
    }
}