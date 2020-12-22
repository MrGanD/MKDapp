import "./Ownable.sol";
import "./provableAPI.sol";

pragma solidity 0.5.12;

contract Flipcoin is Ownable, usingProvable{

    struct Gambler {
        uint fights;
        uint won;
        uint lost;
//PHASE2 ADDITION
        bytes32 provableQuery;
        bool betOnScorpion;
        uint betDeposit;

    }
//EVENTS
    event gamblerRegistered(address adr);
    event fightResult(string messageToGambler, address creator, uint toTransfer);
    event provableQuerySent(string messageToGambler, address creator);
    event generatedRandomNumber(string messageToGambler, address creator, uint256 randomNumber);

        uint public balance;
        uint betDenominator = 0.1 ether;   
//PHASE2 VARIABLES
        uint256 constant MAX_INT_FROM_BYTE = 256;
        uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
        bytes m_proof;
        mapping (address => Gambler) private gambler;
        address payable[] public creators; 
//MODIFIERS
    modifier betValue(uint minFunds){
        require(msg.value >= minFunds);
        _;
    }
//PHASE2 get random number through Oracle
    function queryOracle() payable public returns (bytes32)
    {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        bytes32  queryId = provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );
        emit provableQuerySent("provable queried", msg.sender);
        return queryId;
    }
//PHASE2 oracle callback function for random number
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        require(msg.sender == provable_cbAddress());
        m_proof = _proof; //TODO not used
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
        updateGambler(_queryId, randomNumber);
    }
    function updateGambler(bytes32 queryId, uint256 randomNumber) private{
        address payable creator;
        for (uint i=0; i<creators.length; i++){
            creator = creators[i];
            if (gambler[creator].provableQuery == queryId){
                gambler[creator].provableQuery = 0;
                gambler[creator].provableQuery = 0;
                break;
            }
        }
        emit generatedRandomNumber("created random", creator, randomNumber);
        isWinner(creator, randomNumber);
    }
// fast testing to bypass oracle
    function testRandom() public returns (bytes32){
        bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
        __callback(queryId, "1", bytes("test"));
        emit provableQuerySent("test provable queried", msg.sender);
        return queryId;
    }

//PHASE1 used to fill up the bet pool
    function depositFunds() public payable onlyOwner{
        balance += msg.value;
    }
//check if this is revisiting player
    function isRegistered(address sender) private{
        bool userRegistered = false;
        for (uint i=0; i<creators.length; i++) {
            if (sender == creators[i]){
                userRegistered = true;
                break;
            }
        }
//Register new player
        if(!userRegistered){
            register();
        }
    }

// if the player is first time here, make a new entry
    function register() private{
        Gambler memory newGambler;
        address payable creator = msg.sender;
        
        //This creates a player
        newGambler.lost = 0;
        newGambler.won = 0;
        newGambler.fights = 0;
        newGambler.betDeposit = 0;
        newGambler.provableQuery = 0;
        gambler[creator] = newGambler; //create new gambler entry
        creators.push(creator); //save player's address to creators array
        emit gamblerRegistered(creator);
    }
//PHASE2 gambler placed a bet
    function startFight(bool betOnScorpion) public payable betValue(betDenominator){
        uint betDeposit = msg.value;

        balance += betDeposit;
        isRegistered(msg.sender);
        queryOracle();
        //testRandom();
        gambler[msg.sender].fights++;
        gambler[msg.sender].betDeposit = betDeposit;
        gambler[msg.sender].betOnScorpion = betOnScorpion;
    }

    // compare random with the player's bet
    function isWinner(address payable creator, uint256 randomNumber) private{
        bool betOnScorpion;
        if(randomNumber == 1){
            betOnScorpion = true;
        }
        else if(randomNumber == 0){
            betOnScorpion = false;
        }
        else{
            assert(false);
        }
        if (betOnScorpion == gambler[creator].betOnScorpion) {
            gambler[creator].won++;
            sendFundsToWinner(creator);
            emit fightResult("winner", creator, 1);
        }
        else{
            gambler[creator].lost++;
            emit fightResult("loser", creator, 0);
        }
    }

//if player won, send the reward
    function sendFundsToWinner(address payable creator) private{
       uint toTransfer = gambler[creator].betDeposit * 2;
       balance -= toTransfer;
       creator.transfer(toTransfer);
       emit fightResult("Your fighter won! Funds sent to player ", creator, toTransfer);
    } 
    
//frontend for statistics
    function getGamblerData() public view returns(uint won, uint lost, uint fights){
        address creator = msg.sender;
        return (gambler[creator].won, gambler[creator].lost, gambler[creator].fights);
    }
    function getContractBalance() public view returns (uint){
        return balance;
    }
//Withraw all
    function withdrawAll() public onlyOwner returns(uint) {
       uint toTransfer = balance;
       balance = 0;
       msg.sender.transfer(toTransfer);
       return toTransfer;
    }
}