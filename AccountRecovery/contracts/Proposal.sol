/* Proposal.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/VotingToken.sol";

import "../contracts/Person.sol";
import "../contracts/UserManager.sol";

import "../contracts/Set.sol";

/* <Summary> 
	This contract manages one active proposal: Casts Votes, Tallies votes, give rewards
*/

contract Proposal {
	using Set for Set.Data;

	mapping (address => VotingToken) votingtokens;		// Active Voting Tokens
	Set.Data voters;									// Addresses who are eligible to vote
	address[] haveTradedWith;

	address lastOtherPartner = 0x0000000000000000000000000000000000000000;
	address oldAccount;									// Address of the old account
	address newAccount;									// Address of the new account
	string description;									// Description of Proposal
	
	uint numberOfVoters = 0;
	uint public price;									// Price of the account recovery
	uint8 VotingTokenCreated = 0;						// Number of Voting tokens created
	uint8 randomVoterVetos = 3;
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

	function AddTradePartners(address[] calldata _tradePartners, UserManager UserManagerInstance, TransactionManager TransactionManagerInstance) external {
		require(paided == true, "This proposal has not been paid for yet");

		for (uint i = 0; i < _tradePartners.length; i++){	// For each partner
			if (newAccount != _tradePartners[i]){			// The new account can not be a voter
				// They have made a transaction with the old account
				if (TransactionManagerInstance.NumberOfTransactions(oldAccount, _tradePartners[i]) > 0){
					voters.insert(_tradePartners[i]);
				}
			}
		}
		require(voters.getValuesLength() >= 3, "Invalid Number of tradePartners");
		numberOfVoters = voters.getValuesLength() * 2;

		address[] memory addresses = UserManagerInstance.getAddresses(); // List of addresses on the network

		for (uint i = 0; i < addresses.length; i++){					// For each address
			if (newAccount != addresses[i]){							// The new account can not be a voter
				// They have made a transaction with the old account
				if (TransactionManagerInstance.NumberOfTransactions(oldAccount, addresses[i]) > 0){
					if (!voters.contains(addresses[i])){			// This address is not already a voter
						haveTradedWith.push(addresses[i]);				// This address is an eligible voter
					}
				}
			}
		}
		require(haveTradedWith.length >= 3, "Invalid Number of haveTradedWith");
	}

	function FindRandomTradingPartner() external {
		// require(paided == true, "This proposal has not been paid for yet");
		require(numberOfVoters > 0, "Trade partners have not been added to this yet proposal");
		require(randomVoterVetos > 0, "Can not veto any more random voters");

		randomVoterVetos--;
		uint index = random(lastOtherPartner, haveTradedWith.length);			// Find random value
		
		while(voters.contains(haveTradedWith[index])){
			index = random(lastOtherPartner, haveTradedWith.length);			// Find random value
		}		
		
		lastOtherPartner = haveTradedWith[index];
	}

	function ViewRandomTradingPartner() external view returns (address) {
		// require(lastOtherPartner != 0x0000000000000000000000000000000000000000, "You have not found a random trae partner yet");
		return lastOtherPartner;
	}

	function AddRandomTradingPartner() external {
		// require(paided == true, "This proposal has not been paid for yet");
		// require(voters.getValuesLength() > 0, "Trade partners have not been added to this yet proposal");

		require( lastOtherPartner != 0x0000000000000000000000000000000000000000, "Have to find a random trading partner first");
		require( !voters.contains(lastOtherPartner), "Already added that address");

		randomVoterVetos++;

		voters.insert(lastOtherPartner);
	}

	// Make Voting Tokens
	function MakeVotingToken(address _oldAccount, address _voter, string calldata _description) external {
		// require(paided == true, "This proposal has not been paid for yet");
		require(voters.getValuesLength() == numberOfVoters, "Trade partners have not been added to this yet proposal");
		require(voters.contains(_voter), "Invalid Voter. Can not make a VotingToken");

		votingtokens[_voter] = new VotingToken(_oldAccount, _voter, _description);
		VotingTokenCreated++;			// Incroment the number of voting tokens created
	}

	// Casts a vote
	function CastVote(address _voter, bool choice) external {
		check(_voter);

		votingtokens[_voter].CastVote(choice);
	}

	function CountVotes() private view returns(uint, uint) {
		uint total = 0;							// Total number of votes
		uint yeses = 0;							// Total number of yesses

		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters
			VotingToken temp = votingtokens[voters.getValue(i)];
			if (temp.voted()){			// They are a voter and they voted
				total++;						// Incroment the total number of votes
				if (temp.vote()){ 				// They are a voter and they voted yes
					yeses++;						// Incroment the number of yesses
				}
			}
		}
		return (yeses, total);
	}

	// Give rewards to voters and return outcome of vote
	function ConcludeAccountRecovery(UserManager UserManagerInstance) external returns (bool, bool){
		require(VotingTokenCreated == voters.getValuesLength(), "Have not created all the VotingTokens");

		(uint yeses, uint total) = CountVotes();

		bool outcome = (100*yeses) / total >= 66;			// The outcome of the vote
		bool revote = (100*yeses) / total  >= 60;			// There must be a re-vote

		for (uint i = 0; i < voters.getValuesLength(); i++) { 	// Goes through all voters
			VotingToken temp = votingtokens[voters.getValue(i)];
			if (temp.voted()){							// They are a voter and they voted
				uint amount = (price / 2) / total;				// Reward for participating 
				if (temp.vote() == outcome){				// They voted correctly 
					amount += (price / 2) / yeses;				// Reward for voting correctly 
				}

				Person voter = UserManagerInstance.getUser(voters.getValue(i)); // Gets voter in the network
				voter.increaseBalance(amount);					// Increases balance
			}
		}
		return (outcome, revote);								// Return outcome of vote
	}

	// Add set of data for a give transaction for a give voter
	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, 
		string calldata _description, string calldata _itemsInTrade) external {
		check(_voter);
		votingtokens[_voter].AddTransactionDataSet(_timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation( address _voter, uint i) external view returns (uint, uint, address, address) {
		check(_voter);
		return votingtokens[_voter].ViewPublicInformation(i);
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation( address _voter, uint i) external view returns (string memory, string memory) {
		check(_voter);
		return votingtokens[_voter].ViewPrivateInformation(i);
	}

	// Generate random number using an address
	function random(address address1, uint size) private view returns (uint8) {
		return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, address1, gasleft()))) % size);
	}

	function check(address _voter) private view {
		require(voters.contains(_voter), "Invalid Voter. Can not make a VotingToken");
		require(VotingTokenCreated == voters.getValuesLength(), "Have not created all the VotingTokens");
	} 

	function getVoters() public view returns (address[] memory){
		return voters.getValues();
	}
}
