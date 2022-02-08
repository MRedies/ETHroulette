// SPDX-License-Identifier: CC-BY-SA-4.0

pragma solidity ^0.8.11;

contract roulette{
    struct Bet{
        address payable bettor;
        uint bet_blocknumber;
        uint[] winning_numbers;
        uint winning_amount;
    }

    bool reEntranceMutex = false;
    address owner;
    uint constant security = 1;
    bytes32 random_seed;
    mapping(uint => Bet) bet_list;
    uint first_bet = 1;
    uint last_bet = 0;
    bool accepting_bets = true;

    enum Dozen{low, mid, high}

    modifier shuffle {
        random_seed = keccak256(abi.encodePacked(random_seed,
                                             block.difficulty, 
                                             block.timestamp,
                                             block.coinbase,
                                             gasleft()));
        _;
    }

    modifier payout {
        _;
        payout_winnings();
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You don't own this casino");
        _;
    }

    constructor (){
        owner = msg.sender;
    }

    function push_bet(Bet memory incoming_bet) private {
        last_bet += 1;
        bet_list[last_bet] = incoming_bet;
    }

    function pop_bet() private {
        require(last_bet >= first_bet);
        delete bet_list[first_bet];
        first_bet += 1;
    }

    function place_bet(uint winning_amount, uint[] memory winning_numbers) private {
        require(10 * winning_amount <= address(this).balance, "Stakes to high for me");
        require(accepting_bets, "Casino closed for new bets!");

        for(uint i = 0; i < winning_numbers.length; i++){
            require(winning_numbers[i] > 0 && winning_numbers[i] <= 36, "Numbers must be between 0 and 36");
        }

        push_bet(Bet(payable(msg.sender), block.number, winning_numbers, winning_amount));
    }


    function getrandom(uint nmax) private shuffle returns(uint) {
        uint x = uint(random_seed) % nmax;
        return x;
    }

    function payout_winnings() public shuffle{
        require(!reEntranceMutex);
        uint ball = getrandom(37);
        for(uint i = first_bet; i <= last_bet; i++){
            if(bet_list[i].bet_blocknumber > block.number - security){
                break;
            }else{
                bool won = false;
                for(uint j = 0; j < bet_list[i].winning_numbers.length; j++){
                    if(bet_list[i].winning_numbers[j] == ball){
                        won = true;
                    }
                }

                address payable receipient = bet_list[i].bettor;
                uint amount = bet_list[i].winning_amount;
                pop_bet();
                if(won){
                    reEntranceMutex = true;
                    receipient.transfer(amount);
                    reEntranceMutex = false;
                }
            }
        }

    }

    function bet_odd() payable public payout{
        uint[] memory winning_numbers = new uint[](18);
        for(uint i = 0; i < 18; i++){
            winning_numbers[i] = (i*2) + 1;
        }

        place_bet(2 * msg.value, winning_numbers);
    }

    function bet_even() payable public payout{
        uint[] memory winning_numbers = new uint[](18);
        for(uint i = 0; i < 18; i++){
            winning_numbers[i] = (i+1)*2;
        }
        
        place_bet(2 * msg.value, winning_numbers);
    }

    function bet_single(uint a) payable public payout{
        require(a <= 36 && a >= 0, "Number needs to be between 0 and 36");
        
        uint[] memory winning_numbers = new uint[](1);
        winning_numbers[0] = a;

        place_bet(35 * msg.value, winning_numbers);
    }

    function bet_split(uint a, uint b) payable public payout{
        require(a != b, "Can't bet same number twice");

        uint[] memory winning_numbers = new uint[](2);
        winning_numbers[0] = a;
        winning_numbers[1] = b;

        place_bet(17 * msg.value, winning_numbers);
    }

    function bet_dozen(Dozen doz) payable public payout{
        uint winning_amount = 2 * msg.value;
        require(10 * winning_amount <= address(this).balance, "Stakes to high for me");

        uint shift;
        if(doz == Dozen.low){
            shift = 1;
        }else if(doz == Dozen.mid){
            shift = 13;
        }else{
            shift = 25;
        }

        uint[] memory winning_numbers = new uint[](12);
        for(uint i = 0; i < 12; i++){
            winning_numbers[i] = i + shift;
        }
        push_bet(Bet(payable(msg.sender), block.number, winning_numbers, winning_amount));
    }

    function close_casion() public onlyOwner payout{
        // close casino for new bets
        accepting_bets = false;

        // only payout if every bet has been settled
        if(first_bet > last_bet){
            selfdestruct(payable(owner));
        }
        
    }

    function deposite() external payable onlyOwner{}
} 