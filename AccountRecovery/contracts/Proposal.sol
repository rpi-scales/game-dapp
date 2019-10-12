pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";

contract Proposal {

	mapping (address => VotingToken) tokens;
	address[] voters;
	address oldAccount;
	address newAccount;
	uint public result;

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {
		require(_oldAccount != 0x0000000000000000000000000000000000000000, "There is no oldAccount");
		require(_newAccount != 0x0000000000000000000000000000000000000000, "There is no newAccount");

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;

		for (uint i = 0; i < voters.length; i++) {
			require(voters[i] != 0x0000000000000000000000000000000000000000, "There is no voter");
			tokens[voters[i]] = new VotingToken(voters[i]);
		}
		result = 1;
	}

	function CastVote(address from, bool choice) public {
		tokens[from].CastVote(from, choice);
	}

	function getVotes() public view returns(uint) {
		uint yeses = 0;

		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = tokens[voters[i]];
			if (temp.voted() && temp.vote()){
				yeses++;
			}			
		}
		return yeses;
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

	function getOutcome() public view returns(bool) {
		return result >= 66;
	}

	function AddPublicInformation(address _oldAccount, address _newAccount, uint timeStamp, uint amount, address _voter) public {
		require(newAccount == _newAccount, "Only the owner of this proposal can add public information");
		tokens[_voter].AddPublicInformation(_oldAccount, timeStamp, amount, _voter);
	}

	function AddPrivateInformation(string memory description, string memory itemsInTrade, address _voter) public {
		tokens[_voter].AddPrivateInformation( description, itemsInTrade );
	}

	function ViewPublicInformation( address _voter ) public view returns (uint, uint, address, address) {
		return tokens[_voter].ViewPublicInformation();
	}

	function ViewPrivateInformation( address _voter ) public view returns (string memory, string memory) {
		return tokens[_voter].ViewPrivateInformation();
	}
}
