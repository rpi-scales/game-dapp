pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";

contract Proposal {

	mapping (address => VotingToken) tokens;
	address[] voters;
	address oldAccount;
	address newAccount;
	uint VotingTokenCreated = 0;
	uint public result;

	constructor(address[] memory _voters, address _oldAccount, address _newAccount) public {
		require(_oldAccount != 0x0000000000000000000000000000000000000000, "There is no oldAccount");
		require(_newAccount != 0x0000000000000000000000000000000000000000, "There is no newAccount");

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;
		/*
		for (uint i = 0; i < voters.length; i++) {
			require(voters[i] != 0x0000000000000000000000000000000000000000, "There is no voter");
			tokens[voters[i]] = new VotingToken(voters[i]);
		}
		*/
		result = 1;
	}

	function MakeVotingToken(address _oldAccount, address _newAccount, uint timeStamp, uint amount, address _voter) public{
		require(newAccount == _newAccount, "Only the owner of this proposal can add public information");

		for (uint i = 0; i < voters.length; i++) {
			if (voters[i] == _voter){
				tokens[_voter] = new VotingToken(_oldAccount, timeStamp, amount, _voter);
				VotingTokenCreated++;
				return;
			}
		}
		require(true != true, "Invalid Voter. Can not make a VotingToken");
	}

	function CastVote(address from, bool choice) public {
		tokens[from].CastVote(from, choice);
	}

	function getVotes() public view returns(uint) {
		require(VotingTokenCreated == voters.length, "Have not created all the VotingTokens");
		uint yeses = 0;

		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = tokens[voters[i]];
			if (temp.exists() && temp.voted() && temp.vote()){
				yeses++;
			}			
		}
		return yeses;
	}

	function CountVotes(address from) public {
		require(VotingTokenCreated == voters.length, "Have not created all the VotingTokens");
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
