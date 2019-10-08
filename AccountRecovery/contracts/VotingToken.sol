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
	uint public margin;

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

	function CastVote(bool choice) public {
		require(votes[msg.sender].eligible != false, "Not an eligible voter");
		require(votes[msg.sender].voted != false, "Already Voted");

		// if (votes[msg.sender].eligible == false) return;
		// if (votes[msg.sender].voted == true) return;
		votes[msg.sender].vote = choice;
		votes[msg.sender].eligible = false;
		votes[msg.sender].voted = true;
		emit Vote(msg.sender, choice);
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
