pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

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
	uint public result;

	event Vote(address indexed _from, bool _choice);

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;

		for (uint i = 0; i < voters.length; i++) {
			votes[voters[i]] = token(false, true, false);
		}

		result = 0;	
	}

	function CastVote(address from, bool choice) public {
		require(votes[from].eligible != false, "Not an eligible voter");
		require(votes[from].voted == false, "Already Voted");
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
		return result >= 66;
	}

	function CountVotes(address from) public {
		require(from == newAccount, "Wrong Account");

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

		result = (yeses*100) / total;
	}
}
