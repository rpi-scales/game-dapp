pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";

contract Proposal {

	mapping (address => VotingToken) tokens;
	address[] public voters;
	address public oldAccount;
	address public newAccount;
	uint public result;

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;

		for (uint i = 0; i < voters.length; i++) {
			tokens[voters[i]] = new VotingToken(voters[i]);
		}

		result = 0;	
	}

	function CastVote(address from, bool choice) public {
		tokens[from].CastVote(from, choice);
	}

	function getVotes() public view returns(uint) {
		uint yeses = 0;

		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = tokens[voters[i]];
			if (temp.voted() &&temp.vote()){
				yeses++;
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
			VotingToken temp = tokens[voters[i]];
			if (temp.voted()){
				if (temp.vote()){
					yeses++;
				}
				total++;
			}			
		}

		result = (yeses*100) / total;
	}
}
