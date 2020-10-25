import "./Ownable.sol";
pragma solidity 0.5.12;

contract Flipcoin is Ownable{

    struct Gambler {
        uint fights;
        uint won;
        uint lost;

    }

    event gamblerRegistered(address adr);
    event fightResult(string messageToGambler);
    event fundsSentToGambler(string messageToGambler, uint toTransfer);

        uint public balance;
        uint betDenominator = 0.1 ether;

    modifier betValue(uint minFunds){
        require(msg.value >= minFunds);
        _;
    }

    mapping (address => Gambler) private gambler;
    address[] public creators;
    
    function depositFunds() public payable onlyOwner{
        balance += msg.value;
    }
    
    function register() private{
        Gambler memory newGambler;
        address creator = msg.sender;
        
        //Create a gambler
        newGambler.fights = 0;
        newGambler.won = 0;
        newGambler.lost = 0;

        gambler[creator] = newGambler; //create new gambler entry
        creators.push(creator); //save gambler's address to creators array
        emit gamblerRegistered(creator);
    }
    
    function isRegistered(address sender) private{
        bool userRegistered = false;
        for (uint i=0; i<creators.length; i++) {
            if (sender == creators[i]){
                userRegistered = true;
            }
        }
        //Register before using this contract
        if(!userRegistered){
            register();
        }
    }

    function startFight(bool betOnScorpion) public payable betValue(betDenominator) returns (bool winning){
        uint betDeposit = msg.value;
        balance += betDeposit;
        bool result;
        isRegistered(msg.sender);
        
        gambler[msg.sender].fights++;
        result = isWinner(betOnScorpion, betDeposit) ;
        if (result) {
            gambler[msg.sender].won++;
            emit fightResult("winner");
        }
        else{
            gambler[msg.sender].lost++;
            emit fightResult("loser");
        }
        return result;
    }

    function isWinner(bool betOnScorpion, uint betDeposit) private returns(bool){
        bool flippedRed = randomFlip();
        if (flippedRed && betOnScorpion == true){
            sendFundsToWinner(betDeposit);
            return true;
        }
        else if(!flippedRed && betOnScorpion == false){
            sendFundsToWinner(betDeposit);
            return true;
        }
        else{
            return false;
        }
    }
    
    function randomFlip() private view returns (bool){
        uint256 random = now % 2;
        if (random == 1){
            return true;
        }
        return false;
        }

    function sendFundsToWinner(uint betDeposit) private{
       uint toTransfer = betDeposit * 2;
       balance -= toTransfer;
       msg.sender.transfer(toTransfer);
       emit fundsSentToGambler("Funds sent to gambler ", toTransfer);
    } 
    
    function getGamblerData() public view returns(uint won, uint lost, uint fights){
        address creator = msg.sender;
        return (gambler[creator].won, gambler[creator].lost, gambler[creator].fights);
    }
    
    function getContractBalance() public view returns (uint){
        return balance;
    }

    function withdrawAll() public onlyOwner returns(uint) {
       uint toTransfer = balance;
       balance = 0;
       msg.sender.transfer(toTransfer);
       return toTransfer;
    }

}
