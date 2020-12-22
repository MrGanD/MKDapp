var web3 = new Web3(Web3.givenProvider);
console.log("web3 version = " + web3.version);
var contractInstance;
var userAccount = "0xADDYOURMETAMASKADDRESS";
var contractAddress = "0x8A4f5a640fedA4EB6fD7fb703915f1828B4549F9";
var bookieLimit = 0;
var userLimit = 0;

$(document).ready(function () {
    window.ethereum.enable().then(function (accounts) {
        contractInstance = new web3.eth.Contract(window.abi, contractAddress, {
            from: userAccount
        });
    refreshbalances();
    });
    $("#bet-scorpion").click(betOnScorpion);
    $("#bet-subZero").click(betOnSubZero);
});

function refreshbalances(){
    console.log("Let's refresh bookie and user balance");

    // get contract instance
    contractInstance = new web3.eth.Contract(abi, contractAddress, {from: userAccount});
    $("#userAccount").removeClass("text-danger").addClass("text-success");
    $("#userAccount").text(userAccount);
    console.log(contractInstance);
    
    // get contract balance
    contractInstance.methods.getContractBalance().call()
    .then(function(contractBalance){
        bookieLimit = Web3.utils.fromWei(contractBalance, 'ether');
        console.log("bookie = " + bookieLimit);
        $("#bookieMax").text(bookieLimit);
    });
    
    // get user balance
    web3.eth.getBalance(userAccount)
    .then(function(accountBalance){
        userLimit = Web3.utils.fromWei(accountBalance, 'ether');
        console.log(userLimit);
        $("#userAccountStatus").text(userLimit);
    });
}

function refreshStats(){
    console.log("Refresh statistics");
    contractInstance.methods.getGamblerData().call()
    .then((res) => {
            console.log(res);
            console.log(res["fights"]);
            $("#stat-fight").text("Fights: " + res["fights"]);
            $("#stat-won").text("Won: " + res["won"]);
            $("#stat-lost").text("Lost: " + res["lost"]);
        });
}

function betOnScorpion(){
    betScorpion = true;
    unmarkSubZero(); 
    //betOn(true);
}
function betOnSubZero(){
    betScorpion = false;
    unmarkScorpion(); 
    //betOn(false);
}
function tossCoin () {
        $('#theCoin').addClass('flip-fast');
        betOn(betScorpion);
        /*setTimeout(function(){ 
            unmarkScorpion();
            unmarkSubZero(); }, 1000);*/
      }
function scorpion() {
        $('#coinFront').removeClass('flipped');
        $('#coinBack').addClass('flipped');
}
function subZero() {
        $('#coinBack').removeClass('flipped');
        $('#coinFront').addClass('flipped');
}
function betOn(betScorpion){
    $("#result-text").removeClass("text-danger text-success").addClass("text-white");
    $("#result-text").text("FIGHT!");
    console.log("betScorpion " + betScorpion + " with eth=" + ethValue);
    var ethValue = $("input[name='ethValue']:checked").val();
    contractInstance.methods.startFight(betScorpion).send({value: web3.utils.toWei(ethValue, "ether")})
    .on('transactionHash', function(hash){
      console.log("tx hash, bet");
    })
    .on('confirmation', function(confirmationNumber, receipt){
        console.log("conf");
    })
    .on('receipt', function(receipt){
        console.log(receipt);
    })
    .then((result) => {
            console.log(result["events"]);
            let isWinner = result["events"]["fightResult"]["returnValues"][0];
            console.log("bet result: " + isWinner);
            if (isWinner == "winner") {
                $("#result-text").removeClass("text-white").addClass("text-success");
                $('#theCoin').removeClass('flip-fast');
                if(betScorpion){
                    scorpion();
                    subZeroKilled();
                    scorpionWins.playclip();              
                    $("#result-text").text("Scorpion wins!!! :)");
                }
                else {
                    subZero();
                    scorpionKilled();
                    subZeroWins.playclip();
                    $("#result-text").text("SubZero wins!!! :)");
                }               
            }            
            else {
                $("#result-text").removeClass("text-white").addClass("text-danger");
                $("#result-text").text("You lost :(");
                $('#theCoin').removeClass('flip-fast');
                if(!betScorpion){
                    scorpion();
                    subZeroKilled();
                    scorpionWins.playclip();
                    $("#result-text").text("Scorpion wins... :(");
                }
                else {
                    subZero();
                    scorpionKilled();
                    subZeroWins.playclip();
                    $("#result-text").text("SubZero wins... :(");
                }   
            }
            refreshbalances();
            refreshStats();
        });
}
//play MK music
window.addEventListener('load', function(){
            var myAudio = document.getElementById("myAudio");
            
            myAudio.onplaying = function() {
              isPlaying = true;
            };
            myAudio.onpause = function() {
              isPlaying = false;
            };
        });
        
        var isPlaying = false;
        
        function togglePlay() {
            if (isPlaying) {
                myAudio.pause()
            } else {
                myAudio.play();
            }
        }

 var html5_audiotypes={ //define list of audio file extensions and their associated audio types. Add to it if your specified audio file isn't on this list:
          "mp3": "audio/mpeg",
          "mp4": "audio/mp4",
          "ogg": "audio/ogg",
          "wav": "audio/wav"
        }

        function createsoundbite(sound){
          var html5audio=document.createElement('audio')
          if (html5audio.canPlayType){ //check support for HTML5 audio
            for (var i=0; i<arguments.length; i++){
              var sourceel=document.createElement('source')
              sourceel.setAttribute('src', arguments[i])
              if (arguments[i].match(/\.(\w+)$/i))
                sourceel.setAttribute('type', html5_audiotypes[RegExp.$1])
              html5audio.appendChild(sourceel)
            }
            html5audio.load()
            html5audio.playclip=function(){
              html5audio.pause()
              html5audio.currentTime=0
              html5audio.play()
            }
            return html5audio
          }
          else{
            return {playclip:function(){throw new Error("Your browser doesn't support HTML5 audio unfortunately")}}
          }
        }
        //Initialize sound clips with 1 fallback file each:
     //sound clips by default

var mouseoversound, clicksound, noballssound, hitsound, dblhitsound, entersound, sudden, fivemin, denied, fight, sheep, start;
var clicksound=createsoundbite("audio/announcer/excelent.mp3")
var scorpionSelected=createsoundbite("audio/announcer/scorpionSelected.mp3")
var subZeroSelected=createsoundbite("audio/announcer/subZeroSelected.mp3")
var scorpionWins=createsoundbite("audio/announcer/scorpionWins.mp3")
var subZeroWins=createsoundbite("audio/announcer/subZeroWins.mp3")
var fight=createsoundbite("audio/announcer/fight.mp3")
var flawless=createsoundbite("audio/announcer/flawless.mp3")


function mark(el) {
    el.style.border = "5px groove green";
}
function unmarkScorpion() {
$("#scorpion").css("border", "0");
}
function unmarkSubZero() {
$("#subZero").css("border", "0");
}
function subZeroKilled() {
$("#subZero").css("border", "5px dotted red");
}
function scorpionKilled() {
$("#scorpion").css("border", "5px dotted red");
}