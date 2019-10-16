/* Proposal.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";
import "../contracts/QuizToken.sol";

import "../contracts/Person.sol";
import "../contracts/UserManager.sol";

/* <Summary> 
	This contract manages one active proposal: Casts Votes, Tallies votes, give rewards
*/

contract Proposal {

	mapping (address => VotingToken) votingtokens;		// Active Voting Tokens
	address[] voters;									// Addresses who are eligible to vote

	mapping (address => QuizToken) quizTokens;			// Active Quiz Tokens
	address[] others;									// Addresses connected to these quiz tokens

	address oldAccount;									// Address of the old account
	address newAccount;									// Address of the new account
	string description;									// Description of Proposal

	uint price;											// Price of the account recovery

	uint VotingTokenCreated = 0;						// Number of Voting tokens created

	constructor(address[] memory _voters, address[] memory _others, address _oldAccount, 
		address _newAccount, string memory _description, uint _price) public {
		
		require(_oldAccount != 0x0000000000000000000000000000000000000000, "There is no oldAccount");
		require(_newAccount != 0x0000000000000000000000000000000000000000, "There is no newAccount");

		// Set variable
		oldAccount = _oldAccount;
		newAccount = _newAccount;
		
		voters = _voters;
		others = _others;

		description = _description;
		price = _price;

		// Create Quiz Tokens
		for (uint i = 0; i < others.length; i++){
			quizTokens[others[i]] = new QuizToken();
		}
	}

	// Make Voting Tokens
	function MakeVotingToken(address _oldAccount, address _newAccount, address _voter, string calldata _description) external {
		require(newAccount == _newAccount, "Only the owner of this proposal can make a voting token");

		// Checks if the given voter address is eligible to vote
		for (uint i = 0; i < voters.length; i++) {
			if (voters[i] == _voter){			// The address is eligible to vote
				votingtokens[_voter] = new VotingToken(_oldAccount, _voter, _description);
				VotingTokenCreated++;			// Incroment the number of voting tokens created
				return;
			}
		}
		require(true != true, "Invalid Voter. Can not make a VotingToken");
	}

	// Casts a vote
	function CastVote(address from, bool choice) external {
		votingtokens[from].CastVote(from, choice);
	}

	// Counts total number of votes
	function NumberOfVotes() internal view returns (uint) {
		uint total = 0;							// Total number of votes
		for (uint i = 0; i < voters.length; i++) { // Goes through all voters
			VotingToken temp = votingtokens[voters[i]];
			if (temp.ExistsAndVoted()){	// They are a voter and they voted
				total++;						// Incroment the total number of votes
			}
		}
		return total;
	}

	// Counts the number of yess votes
	function CountYesses() internal view returns(uint) {
		uint yeses = 0;							// Total number of yesses
		for (uint i = 0; i < voters.length; i++) { // Goes through all voters
			VotingToken temp = votingtokens[voters[i]];
			if (temp.VotedYes()){ // They are a voter and they voted yes
				yeses++;						// Incroment the number of yesses
			}			
		}
		return yeses;
	}

	// Give rewards to voters and return outcome of vote
	function ConcludeAccountRecovery(UserManager UserManagerInstance) external returns (bool){
		require(VotingTokenCreated == voters.length, "Have not created all the VotingTokens");

		// Decides the outcome of the vote
		bool outcome = (CountYesses()*100) / NumberOfVotes() >= 66;

		for (uint i = 0; i < voters.length; i++) {				// Goes through all voters
			VotingToken temp = votingtokens[voters[i]];
			if (temp.ExistsAndVoted()){					// They are a voter and they voted
				uint amount = (price / 2) / NumberOfVotes();	// Reward for participating 
				if (temp.VotedYes() == outcome){					// They voted correctly 
					amount += (price / 2) / CountYesses();		// Reward for voting correctly 
				}

				Person voter = UserManagerInstance.getUser(voters[i]); // Gets voter in the network
				voter.increaseBalance(amount);					// Increases balance
			}
		}
		return outcome;											// Return outcome of vote
	}

	// Add set of data for a give transaction for a give voter
	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, 
		string calldata _description, string calldata _itemsInTrade) external {
		votingtokens[_voter].AddTransactionDataSet(_timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation( address _voter, uint i) external view returns (uint, uint, address, address) {
		return votingtokens[_voter].ViewPublicInformation(i);
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation( address _voter, uint i) external view returns (string memory, string memory) {
		return votingtokens[_voter].ViewPrivateInformation(i);
	}
}
