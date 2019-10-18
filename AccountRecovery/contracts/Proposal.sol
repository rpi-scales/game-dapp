/* Proposal.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";

import "../contracts/Person.sol";
import "../contracts/UserManager.sol";

/* <Summary> 
	This contract manages one active proposal: Casts Votes, Tallies votes, give rewards
*/

contract Proposal {
	mapping (address => VotingToken) votingtokens;		// Active Voting Tokens
	address[] voters;									// Addresses who are eligible to vote

	address[] haveTradedWith;

	address lastOtherPartner = 0x0000000000000000000000000000000000000000;

	address oldAccount;									// Address of the old account
	address newAccount;									// Address of the new account
	string description;									// Description of Proposal

	uint price;											// Price of the account recovery

	uint8 VotingTokenCreated = 0;						// Number of Voting tokens created

	bool paided = false;

	constructor(address _oldAccount, address _newAccount, string memory _description, uint _price) public {
		// Set variable
		oldAccount = _oldAccount;
		newAccount = _newAccount;
		
		description = _description;
		price = _price;
	}

	function Pay(Person _newAccount) external {
		require(_newAccount.balance() >= price, "Not Enough funds for this Proposal");
		_newAccount.decreaseBalance(price);			// Removes money from the new account
		paided = true;								// The proposal has been paid for
	}

	function AddTradePartners(address[] calldata _voters, address[] calldata _haveTradedWith) external {
		require(paided == true, "This proposal has not been paid for yet");
		voters = _voters;
		haveTradedWith = _haveTradedWith;
	}

	function FindRandomTradingPartner() external {
		require(paided == true, "This proposal has not been paid for yet");
		require(voters.length > 0, "Trade partners have not been added to this yet proposal");

		uint index = random(lastOtherPartner, haveTradedWith.length);			// Find random value

		/*
		for (uint i = 0; i < voters.length; i++){
			while(haveTradedWith[index] != voters[i]){

			}
		}
		*/
		lastOtherPartner = haveTradedWith[index];






	}

	function ViewRandomTradingPartner() external view returns (address) {
		require(lastOtherPartner != 0x0000000000000000000000000000000000000000, "You have not found a random trae partner yet");
		return lastOtherPartner;
	}

	function AddRandomTradingPartner() external {
		require(paided == true, "This proposal has not been paid for yet");
		require(voters.length > 0, "Trade partners have not been added to this yet proposal");

		require( lastOtherPartner != 0x0000000000000000000000000000000000000000, "Have to find a random trading partner first");
		// require( otherPartners[otherPartners.length - 1] != lastOtherPartner, "Already added that address");

		voters.push(lastOtherPartner);
	}

	// Make Voting Tokens
	function MakeVotingToken(address _oldAccount, address _voter, string calldata _description) external {
		require(paided == true, "This proposal has not been paid for yet");
		require(voters.length > 0, "Trade partners have not been added to this yet proposal");

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
		check();

		votingtokens[from].CastVote(from, choice);
	}

	// Counts total number of votes
	function NumberOfVotes() internal view returns (uint) {
		check();

		uint total = 0;							// Total number of votes
		for (uint i = 0; i < voters.length; i++) { // Goes through all voters
			VotingToken temp = votingtokens[voters[i]];
			if (temp.ExistsAndVoted()){			// They are a voter and they voted
				total++;						// Incroment the total number of votes
			}
		}
		return total;
	}

	// Counts the number of yess votes
	function CountYesses() internal view returns(uint) {
		check();

		uint yeses = 0;							// Total number of yesses
		for (uint i = 0; i < voters.length; i++) { // Goes through all voters
			VotingToken temp = votingtokens[voters[i]];
			if (temp.VotedYes()){ 				// They are a voter and they voted yes
				yeses++;						// Incroment the number of yesses
			}			
		}
		return yeses;
	}

	// Give rewards to voters and return outcome of vote
	function ConcludeAccountRecovery(UserManager UserManagerInstance) external returns (bool){
		check();

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
		check();
		votingtokens[_voter].AddTransactionDataSet(_timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation( address _voter, uint i) external view returns (uint, uint, address, address) {
		check();
		return votingtokens[_voter].ViewPublicInformation(i);
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation( address _voter, uint i) external view returns (string memory, string memory) {
		check();
		return votingtokens[_voter].ViewPrivateInformation(i);
	}

	// Generate random number using an address
	function random(address address1, uint size) internal view returns (uint8) {
		return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, address1))) % size);
	}

	function check() internal view {
		require(paided == true, "This proposal has not been paid for yet");
		require(voters.length > 0, "Trade partners have not been added to this yet proposal");
		require(VotingTokenCreated == voters.length, "Have not created all the VotingTokens");
	}
}
