pragma solidity ^0.8.0;
//@title Game where two players enter equal amounts with a random payout of both amounts to one
contract RandomPayoutGame {
    uint public value;
    enum State { Created, Locked, Inactive, Finished }
    State public state;
    address payable public player1;
    address payable public player2;
    error InvalidState();
    error OnlyPlayer1();
    error OnlyPlayer2();
    uint256[] chamber;
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    event TwoPlayersPaidIn();
    event Player1Loses();
    event Player1Wins();
    event Player2Loses();
    event Player2Wins();
     modifier inState(State _state) {
        if (state != _state)
            revert InvalidState();
        _;
    }
    modifier onlyPlayer2(){
        if(msg.sender!=player2){
            revert OnlyPlayer2();
        }
        _;
    }
    modifier onlyPlayer1(){
        if(msg.sender!=player1){
            revert OnlyPlayer1();
        }
        _;
    }
    constructor() payable{
        player1 = payable(msg.sender);
        value = msg.value;
    }
    
    function rand()
    public
    view
    returns(uint256)
    {
    uint256 seed = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number
    )));

    return (seed - ((seed / 1000) * 1000));
    }
    
    function randInRange() internal view returns(uint256){
        uint256 randInt = rand();
        randInt=randInt%6;
        return randInt;
    }
    
    function player2paysin() public inState(State.Created) condition(msg.value==value) payable{
        emit TwoPlayersPaidIn();
        player2 = payable(msg.sender);
        state=State.Locked;
    }
    
    function play() public onlyPlayer1 inState(State.Locked){
        uint256 loserNumber = randInRange();
        if(loserNumber%2==0){
            emit Player1Loses();
            state=State.Finished;
            player2Wins();
        }
        else{
            emit Player2Loses();
            state=State.Inactive;
            player1Wins();
        }
    }
    
    function player1Wins() public inState(State.Finished){
        emit Player1Wins();
        state = State.Inactive;
        player1.transfer(2*value);
    }
    
    function player2Wins() public inState(State.Finished){
        emit Player2Wins();
        state=State.Inactive;
        player2.transfer(2*value);
    }
}
