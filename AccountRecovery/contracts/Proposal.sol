pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";
import "../contracts/QuizToken.sol";

contract Proposal {

	mapping (address => VotingToken) tokens;
	address[] voters;

	mapping (address => QuizToken) quizTokens;
	address[] others;


	address oldAccount;
	address newAccount;
	string description;

	uint VotingTokenCreated = 0;
	uint public result = 1;

	constructor(address[] memory _voters, address[] memory _others, address _oldAccount, address _newAccount, string memory _description) public {
		require(_oldAccount != 0x0000000000000000000000000000000000000000, "There is no oldAccount");
		require(_newAccount != 0x0000000000000000000000000000000000000000, "There is no newAccount");

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;
		description = _description;

		others = _others;

		for (uint i = 0; i < others.length; i++){
			quizTokens[others[i]] = new QuizToken();
		}
	}

	function MakeVotingToken(address _oldAccount, address _newAccount, address _voter, string memory _description) public{
		require(newAccount == _newAccount, "Only the owner of this proposal can add public information");

		for (uint i = 0; i < voters.length; i++) {
			if (voters[i] == _voter){
				tokens[_voter] = new VotingToken(_oldAccount, _voter, _description);
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

	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, string memory _description, string memory _itemsInTrade) public {
		tokens[_voter].AddTransactionDataSet(_timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	function ViewPublicInformation( address _voter, uint i) public view returns (uint, uint, address, address) {
		return tokens[_voter].ViewPublicInformation(i);
	}

	function ViewPrivateInformation( address _voter, uint i) public view returns (string memory, string memory) {
		return tokens[_voter].ViewPrivateInformation(i);
	}
}
