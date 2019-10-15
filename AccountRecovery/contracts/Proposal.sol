pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";
import "../contracts/QuizToken.sol";

import "../contracts/Person.sol";

import "../contracts/UserManager.sol";

contract Proposal {

	mapping (address => VotingToken) votingtokens;
	address[] voters;

	mapping (address => QuizToken) quizTokens;
	address[] others;


	address oldAccount;
	address newAccount;
	string description;

	uint price;

	uint VotingTokenCreated = 0;
	uint public result = 0;

	constructor(address[] memory _voters, address[] memory _others, address _oldAccount, address _newAccount, string memory _description, uint _price) public {
		require(_oldAccount != 0x0000000000000000000000000000000000000000, "There is no oldAccount");
		require(_newAccount != 0x0000000000000000000000000000000000000000, "There is no newAccount");

		oldAccount = _oldAccount;
		newAccount = _newAccount;
		voters = _voters;
		description = _description;

		price = _price;

		others = _others;

		for (uint i = 0; i < others.length; i++){
			quizTokens[others[i]] = new QuizToken();
		}
	}

	function MakeVotingToken(address _oldAccount, address _newAccount, address _voter, string memory _description) public{
		require(newAccount == _newAccount, "Only the owner of this proposal can make a voting token");

		for (uint i = 0; i < voters.length; i++) {
			if (voters[i] == _voter){
				votingtokens[_voter] = new VotingToken(_oldAccount, _voter, _description);
				VotingTokenCreated++;
				return;
			}
		}
		require(true != true, "Invalid Voter. Can not make a VotingToken");
	}

	function CastVote(address from, bool choice) public {
		votingtokens[from].CastVote(from, choice);
	}


	function NumberOfVotes() internal view returns (uint) {
		uint total = 0;
		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = votingtokens[voters[i]];
			if (temp.exists() && temp.voted()){
				total++;
			}
		}
		return total;
	}

	function getVotes() internal view returns(uint) {
		uint yeses = 0;

		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = votingtokens[voters[i]];
			if (temp.exists() && temp.voted() && temp.vote()){
				yeses++;
			}			
		}
		return yeses;
	}

	function ConcludeAccountRecovery(UserManager UserManagerInstance) public returns (bool){
		require(VotingTokenCreated == voters.length, "Have not created all the VotingTokens");

		bool outcome = (getVotes()*100) / NumberOfVotes() >= 66;

		for (uint i = 0; i < voters.length; i++) {
			VotingToken temp = votingtokens[voters[i]];
			if (temp.exists() && temp.voted()){
				uint amount = (price / 2) / NumberOfVotes();

				if (temp.vote() == outcome){
					amount += (price / 2) / getVotes();
				}

				Person voter = UserManagerInstance.getUser(voters[i]);
				voter.increaseBalance(amount);
			}
		}
	}

	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, string memory _description, string memory _itemsInTrade) public {
		votingtokens[_voter].AddTransactionDataSet(_timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	function ViewPublicInformation( address _voter, uint i) public view returns (uint, uint, address, address) {
		return votingtokens[_voter].ViewPublicInformation(i);
	}

	function ViewPrivateInformation( address _voter, uint i) public view returns (string memory, string memory) {
		return votingtokens[_voter].ViewPrivateInformation(i);
	}
}
