/* Proposal.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/UserManager.sol";

import "../contracts/Set.sol";
import "../contracts/VotingToken.sol";
import "../contracts/TransactionDataSet.sol";

/* <Summary> 
	This contract manages one active proposal: Pays for proposal, Adds indicated 
	 trade partners, finds random voters, manages transaction data, casts votes, 
	 tallies votes, and give rewards
*/

contract Proposal {
	using Set for Set.AddressData;					// Set of addresses
	using VotingToken for VotingToken.Token;		// Voting token
	// Struct full of transaction data
	using TransactionDataSet for TransactionDataSet.DataSet;

	// Map of lists of transaction data. [voter] -> list of data
	mapping (address => TransactionDataSet.DataSet[]) transactionDataSets;
	// Map of voting tokens. [voter] -> voting token
	mapping (address => VotingToken.Token) votingtokens;

	Set.AddressData voters;				// Addresses who are eligible to vote
	Set.AddressData archivedVoters;		// Archived voters from past proposals

	address[] haveTradedWith;			// all of old accounts trading partners

	address public lastOtherPartner;	// Last randomly selected voter
	
	uint numberOfVoters;				// Number of required voters
	uint public price;					// Price of the account recovery
	uint startTime;						// The start of voting
	uint8 VotingTokensCreated;			// Number of Voting tokens created
	uint8 randomVoterVetos = 3;			// Number of vetos left
	bool paided;						// If the user has paid yet

	constructor(uint _price) public {
		price = _price;					// Price of the proposal
	}

	// Allows the new account to pay for the proposal
	function Pay(Person _newAccount) external {
		require(_newAccount.balance() >= price, "Not Enough funds for this Proposal");
		_newAccount.decreaseBalance(price);		// Removes money from the new account
		paided = true;							// The proposal has been paid for
	}

	function AddTradePartners(address _newAccount, address _oldAccount, 
		address[] calldata _tradePartners, address[] calldata _archivedVoters, 
		TransactionManager TMI, ProposalManager PMI) external {

		// Checks that the new account has paid
		require(paided, "This proposal has not been paid for yet");

		// Creates the archivedVoters set
		for (uint i = 0; i < _archivedVoters.length; i++){
			archivedVoters.insert(_archivedVoters[i]);
		}

		// Checks given trade partners and sets them as voters
		for (uint i = 0; i < _tradePartners.length; i++){	// For each given partner

			// The new account can not be a voter
			if (_newAccount != _tradePartners[i]){

				// Checks if the trade partner is black listed		
				if (!PMI.getBlacklistedAccount(_tradePartners[i])){

					// Makes sure they are actually trade partners
					if (TMI.NumberOfTransactions(_oldAccount, _tradePartners[i]) > 0){

						// Voter was a voter in a past proposal for this account
						if (!archivedVoters.contains(_tradePartners[i])){

							// Has not already been indicated as a trade partner
							if (!voters.contains(_tradePartners[i])){

								// Make the trade partner a voter
								voters.insert(_tradePartners[i]);
							}
						}
					}
				}
			}
		}

		/*
		// Requires at least 3 indicated valid voters 
		require(voters.getValuesLength() >= 2, 
			"Invalid Number of indicated trade partners");
		*/

		// Requires a maximum of 3 invlaid indicated trade partners
		require(_tradePartners.length - voters.getValuesLength() < 3, 
			"You indicated too many invalid trade partners");

		// Sets the required number of voters
		numberOfVoters = voters.getValuesLength() * 2;
		if (numberOfVoters < 5){				// Requires at least 5 voters
			numberOfVoters = 5;
		}

		// Finds all of the old accounts's trade partners
		address[] memory _haveTradedWith = TMI.getHaveTradedWith(_oldAccount);

		// Checks if these trade partners are valid to be randomly selected voters
		for (uint i = 0; i < _haveTradedWith.length; i++){		// For each address

			// The new account can not be a voter
			if (_newAccount != _haveTradedWith[i]){

				// The were not already indicated as a voter
				if (!voters.contains(_haveTradedWith[i])){

					// They were not a voter in a past proposal for this account
					if (!archivedVoters.contains(_haveTradedWith[i]) ){

						// This address is an eligible voter
						haveTradedWith.push(_haveTradedWith[i]);				
					}
				}
			}
		}

		require(haveTradedWith.length >= numberOfVoters - voters.getValuesLength(), 
			"Invalid number of other trade partners");

		// Find the first randomly selected voter
		RandomTradingPartner(true);
		randomVoterVetos++;
	}

	// Adds last randomly selected voter and finds the next one
	function RandomTradingPartner(bool _veto) public {

		require(numberOfVoters != 0, 
			"Trade partners have not been added to this yet proposal");

		// The new account remembers their transaction with this account
		if (!_veto){

			// This voter has not already been added to be a voter
			require(!voters.contains(lastOtherPartner), "Already added that address");

			// Makes the selected trade partner a voter
			voters.insert(lastOtherPartner);
		}else{
			randomVoterVetos--;
		}

		// Select another trade partner randomly 
		if (voters.getValuesLength() != numberOfVoters){ 	// Needs to find more partners
			require(randomVoterVetos >= 0, 
				"Can not veto any more randomly selected voters");
			require(haveTradedWith.length >= numberOfVoters - voters.getValuesLength(), 
				"Can not veto this voter because there is not enough trade partners left");

			// Finds a random index in the haveTradedWith array
			uint index = random(lastOtherPartner, haveTradedWith.length);
			
			// Finds the randomly selected trade partner
			lastOtherPartner = haveTradedWith[index];

			// Remove this trade partner from the list
			for (uint i = index; i < haveTradedWith.length - 1; i++){
				haveTradedWith[i] = haveTradedWith[i+1];  	// Shift other address
			}
			delete haveTradedWith[haveTradedWith.length-1]; // Remove address
			haveTradedWith.length--;						// Reduce size
		}
	}

	// Add set of data for a give transaction for a give voter
	function AddTransactionDataSet(address _voter, uint _timeStamp, uint _amount, 
		string calldata _description, string calldata _importantNotes, 
		string calldata _location, string calldata _itemsInTrade) external {


		// If this is the first set transaction data being added for this voter
		if (transactionDataSets[_voter].length == 0){

			// Create a voting token for this voter
			votingtokens[_voter] = VotingToken.Token(0, false, false);
			VotingTokensCreated++;

			// If all voters are able to vote now
			if (VotingTokensCreated == voters.getValuesLength()){
				startTime = block.timestamp;	// Start the timer on the voters
			}
		}

		// Create the data set and add it to the list for this voter
		transactionDataSets[_voter].push(TransactionDataSet.DataSet(
			_description, _importantNotes, _location, _itemsInTrade,
			_timeStamp, _amount));
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation( address _voter, uint i) 
		external view returns (uint, uint) {

		// Require that all voters are able to voter
		require(VotingTokensCreated == voters.getValuesLength(), 
			"Have not created all the VotingTokens");

		// Return transaction data
		return transactionDataSets[_voter][i].ViewPublicInformation();
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation( address _voter, uint i) 
		external view returns (string memory, string memory, 
			string memory, string memory) {

		// Require that all voters are able to voter
		require(VotingTokensCreated == voters.getValuesLength(), 
			"Have not created all the VotingTokens");

		// Return transaction data
		return transactionDataSets[_voter][i].ViewPrivateInformation();
	}

	// Casts a vote
	function CastVote(address _voter, bool choice) external {

		// Require that all voters are able to voter
		require(VotingTokensCreated == voters.getValuesLength(), 
			"Have not created all the VotingTokens");

		votingtokens[_voter].CastVote(_voter, choice);	// Casts the vote
	}

	// Give rewards to voters and return the outcome of the vote
	function ConcludeProposal(uint vetoTime, UserManager UMI) external returns (int){

		// Require that all voters are able to voter
		require(VotingTokensCreated == voters.getValuesLength(), 
			"Have not created all the VotingTokens");

		// Require that enough time has passed for the old account to veto an attack
		if (vetoTime > block.timestamp - startTime){
			return -1;
		}

		uint total = 0;							// Total number of votes
		uint yeses = 0;							// Total number of yesses
		uint totalTimeToVote = 0;				// Total time used to vote

		// Counts votes and find the time required for all voters to vote
		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters

			// Get voting token for voter
			VotingToken.Token storage temp = votingtokens[voters.getValue(i)];

			// Incroment totalTimeToVote by the amount of time used by the voter
			totalTimeToVote += temp.getVotedTime();

			// Count votes
			if (temp.getVoted()){				// They are a voter and they voted
				total++;						// Incroment the total number of votes
				if (temp.getVote()){ 			// They are a voter and they voted yes
					yeses++;					// Incroment the number of yesses
				}
			}
		}

		// Requires a certain number of voters to vote before concluding the vote
		if (total < (numberOfVoters*3)/4){
			// If enough time has passed allow a revote
			if (block.timestamp - startTime > 172800){
				return 60;
			}
			return -2;							// Require more votes
		}

		bool outcome = (100*yeses) / total >= 66;	// The outcome of the vote

		// Factors used in determining the requare for voters
		uint participationFactor = 2;			// Participation factor
		uint correctionFactor = 2;				// Correction factor
		uint timeFactor = 1;					// Time factor

		// Average time used to vote
		uint averageTimeToVote = totalTimeToVote / total;

		// Rewards voters
		for (uint i = 0; i < voters.getValuesLength(); i++) { 	// Goes through all voters

			// Get voting token for voter
			VotingToken.Token storage temp = votingtokens[voters.getValue(i)];

			if (temp.getVoted()){		// If the voter has voted

				// Reward for participating 
				uint amount = (price / participationFactor) / total;			

				// They voted correctly
				if (outcome == temp.getVote()){
					if (outcome){		// Yes was the correct vote 
						// Reward for voting correctly 
						amount += (price / correctionFactor) / yeses;
					}else{				// No was the correct vote 
						// Reward for voting correctly
						amount += (price / correctionFactor) / (total-yeses);
					}
				}

				// Reward based on the time used to vote
				//  If they took less time than average they gain more money
				amount += (averageTimeToVote - temp.getVotedTime()) / timeFactor;

				if (amount > 0){	// The user actually did get a reward

					// Increases balance of the voter
					UMI.getUser(voters.getValue(i)).increaseBalance(amount);
				}
			}
		}
		return int((100*yeses) / total);	// Return outcome of vote
	}

	// Generate random number using an address
	function random(address address1, uint size) private view returns (uint8) {
		return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, 
			block.difficulty, address1, gasleft()))) % size);
		// return uint8(uint256(keccak256(abi.encodePacked(block.difficulty, block.coinbase, address1, gasleft()))) % size);
	}

	// Return voters
	function getVoters() external view returns (address[] memory){
		return voters.getValues();
	}

	// Returns true is an address is a voter
	function ContainsVoter(address _voter) external view returns (bool) {
		return voters.contains(_voter);
	}
}
