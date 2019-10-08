pragma solidity >=0.4.0 <0.7.0;

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
