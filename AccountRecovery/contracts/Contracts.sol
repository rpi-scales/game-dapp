pragma solidity >=0.4.25 <0.6.0;

/*
contract Coins {
	mapping (address => uint) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		balances[tx.origin] = 10000;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(msg.sender, receiver, amount);
		return true;
	}

	function getBalance(address addr) public view returns(uint) {
		return balances[addr];
	}
}
*/

contract VotingToken {

	struct token {
		bool vote;
		bool eligible;
		bool voted;
	}

	mapping (address => token) votes;
	address[] public voters;
	address public oldAccount;
	address public newAccount;

	event Vote(address indexed _from, bool _choice);

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;

		for (uint i = 0; i < voters.length; i++) {
			votes[voters[i]] = token(false, true, false);
		}		
	}

	function CastVote(address from, bool choice) public {
		if (votes[from].eligible == false) return;
		if (votes[from].voted == true) return;
		votes[from].vote = choice;
		votes[from].eligible = false;
		votes[from].voted = true;
		emit Vote(from, choice);
	}

	function getVotes() public view returns(uint) {
		uint yeses = 0;

		for (uint i = 0; i < voters.length; i++) {
			token memory temp = votes[voters[i]];
			if (temp.voted == true){
				if (temp.vote == true){
					yeses++;
				}
			}			
		}
		return yeses;

	}

	function CountVotes(address from) public view returns(bool) {
		if (from != newAccount) return false;

		uint yeses = 0;
		uint total = 0;

		uint margin = 5;

		for (uint i = 0; i < voters.length; i++) {
			token memory temp = votes[voters[i]];
			if (temp.voted == true){
				if (temp.vote == true){
					yeses++;
				}
				total++;
			}			
		}
		
		if ( (yeses / total * 10 ) >= margin){
			return true;
		}
		return false;
	}

}




/*
contract Inventory {

	mapping (address => GameObject) Coins;
	mapping (address => GameObject) Item;

	event Buy(address indexed _buyer, uint256 _price);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		Coins[tx.origin] = new GameObject(10000);
		Item[tx.origin] = new GameObject(0);
	}

	function incrementBalance(address addr, uint amount) external {
		Coins[addr].incrementBalance(amount);
	}

	function buy(uint price) external returns(bool sufficient) {
		if (Coins[msg.sender].getBalance() < price) return false;

		Coins[msg.sender].decrementBalance(price);

		// return G.buy(price);

		Item[msg.sender].incrementBalance(1);
		emit Buy(msg.sender, price);
		return true;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (Coins[msg.sender].getBalance() < amount) return false;

		Coins[msg.sender].decrementBalance(amount);
		Coins[receiver].incrementBalance(amount);
		emit Transfer(msg.sender, receiver, amount);

		return true;
	}


	function getItemBalance(address addr) external view returns (uint) {
		return Item[addr].getBalance();
	}

	function getCoinBalance(address addr) external view returns (uint) {
		return Coins[addr].getBalance();
	}


}

contract GameObject {
	
	uint balance;

	constructor(uint amount) public {
		balance = amount;
	}

	function getBalance() external view returns(uint) {
		return balance;
	}

	function incrementBalance(uint amount) public {
		balance += amount;
	}

	function decrementBalance(uint amount) public {
		balance -= amount;
	}

	function setBalance(uint amount) public {
		balance = amount;
	}
}
*/
