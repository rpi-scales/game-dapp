pragma solidity >=0.4.0 <0.7.0;

contract Person {
	address public ID;
	uint public balance;

	constructor(address _ID, uint _balance) public {
		ID = _ID;
		balance = _balance;
	}
}

contract Manager {
	mapping (address => Person) Users;
	address[] addresses;

	constructor(address[] memory _addresses) public {
		addresses = _addresses;
		for (uint i = 0; i < addresses.length; i++) {
			Users[addresses[i]] = new Person(addresses[i], 100);
		}
	}

	function getUserBalance(uint i) public view returns(uint) {
		return Users[addresses[i]].balance();
	}
	function getUserID(uint i) public view returns(address) {
		return Users[addresses[i]].ID();
	}
}

/*
contract Transaction {

	Person public sender;
	Person public receiver;
	uint public amount;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor(Person _sender, Person _reciever, uint _amount) public {
		sender = _sender;
		receiver = _reciever;
		amount = _amount;
		sendCoin();
	}

	function sendCoin() public pure returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(msg.sender, receiver, amount);
		return true;
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
	uint256 public result;
	uint256 public margin;

	event Vote(address indexed _from, bool _choice);

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;

		for (uint i = 0; i < voters.length; i++) {
			votes[voters[i]] = token(false, true, false);
		}

		result = 0;	
		margin = 6;
	}

	function random(uint8 size) public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%size);
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

	function getOutcome() public view returns(bool) {
		return result >= margin;
	}

	function getResult() public view returns(uint256) {
		return result;
	}

	function CountVotes(address from) public {
		if (from != newAccount) return;

		uint yeses = 0;
		uint total = 0;

		for (uint i = 0; i < voters.length; i++) {
			token memory temp = votes[voters[i]];
			if (temp.voted == true){
				if (temp.vote == true){
					yeses++;
				}
				total++;
			}			
		}

		result = (yeses*10) / total;
	}
}
