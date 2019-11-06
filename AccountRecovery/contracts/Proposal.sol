/* Proposal.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/UserManager.sol";

import "../contracts/Set.sol";
import "../contracts/VotingToken.sol";
import "../contracts/TransactionDataSet.sol";

/* <Summary> 
	This contract manages one active proposal: Casts Votes, Tallies votes, give rewards
*/

contract Proposal {
	using Set for Set.AddressData;
	using VotingToken for VotingToken.Token;
	using TransactionDataSet for TransactionDataSet.DataSet;

	struct VotingTokenPair {
		VotingToken.Token token;
		bool exists;
	}

	mapping (address => TransactionDataSet.DataSet[]) transactionDataSets; // Map of active proposals

	mapping (address => VotingTokenPair) votingtokens;		// Active Voting Tokens
	Set.AddressData voters;									// Addresses who are eligible to vote
	Set.AddressData archivedVoters;

	address[] haveTradedWith;

	address public lastOtherPartner = 0x0000000000000000000000000000000000000000;
	address oldAccount;									// Address of the old account
	address newAccount;							// Address of the new account
	
	uint numberOfVoters = 0;
	uint public price;									// Price of the account recovery
	uint startTime;
	uint8 VotingTokenCreated = 0;						// Number of Voting tokens created
	uint8 randomVoterVetos = 3;
	bool paided = false;


	constructor(address _oldAccount, address _newAccount, uint _price) public {
		// Set variable
		oldAccount = _oldAccount;
		newAccount = _newAccount;
		
		price = _price;
		startTime = block.timestamp;
	}

	function Pay(Person _newAccount) external {
		require(_newAccount.balance() >= price, "Not Enough funds for this Proposal");
		_newAccount.decreaseBalance(price);			// Removes money from the new account
		paided = true;								// The proposal has been paid for
	}

	function AddTradePartners(address[] calldata _tradePartners, address[] calldata _archivedVoters, TransactionManager TMI, ProposalManager PMI) external {
		require(paided == true, "This proposal has not been paid for yet");

		for (uint i = 0; i < _archivedVoters.length; i++){
			archivedVoters.insert(_archivedVoters[i]);
		}

		for (uint i = 0; i < _tradePartners.length; i++){	// For each partner
			if (newAccount != _tradePartners[i]){			// The new account can not be a voter
				if (!PMI.getBlacklistedAccount(_tradePartners[i], _tradePartners[i])){
					// They have made a transaction with the old account
					if (TMI.NumberOfTransactions(oldAccount, _tradePartners[i]) > 0){
						if (!archivedVoters.contains(_tradePartners[i])){			// This address is not already a voter
							voters.insert(_tradePartners[i]);
						}
					}
				}
			}
		}
		require(voters.getValuesLength() >= 3, "Invalid Number of indicated trade partners");
		require(_tradePartners.length - voters.getValuesLength() < 3, "You indicated to0 many invalid trade partners");
		numberOfVoters = voters.getValuesLength() * 2;

		address[] memory _haveTradedWith = TMI.getHaveTradedWith(oldAccount, newAccount);

		for (uint i = 0; i < _haveTradedWith.length; i++){					// For each address
			if (!voters.contains(_haveTradedWith[i]) && !archivedVoters.contains(_haveTradedWith[i]) ){			// This address is not already a voter
				haveTradedWith.push(_haveTradedWith[i]);				// This address is an eligible voter
			}
		}
		require(haveTradedWith.length >= voters.getValuesLength(), "Invalid Number of haveTradedWith");
		RandomTradingPartner(true);
	}

	function RandomTradingPartner(bool _veto) public {
		if (!_veto){
			require(!voters.contains(lastOtherPartner), "Already added that address");
			randomVoterVetos++;
			voters.insert(lastOtherPartner);
		}

		if (voters.getValuesLength() != numberOfVoters){
			require(numberOfVoters > 0, "Trade partners have not been added to this yet proposal");
			require(randomVoterVetos > 0, "Can not veto any more random voters");
			require(haveTradedWith.length > 0, "Can not veto this voter because there is not enough trade partners left");

			randomVoterVetos--;
			uint index = random(lastOtherPartner, haveTradedWith.length);			// Find random value
					
			lastOtherPartner = haveTradedWith[index];

			for (uint i = index; i < haveTradedWith.length - 1; i++){
				haveTradedWith[i] = haveTradedWith[i+1];
			}
			delete haveTradedWith[haveTradedWith.length-1];
			haveTradedWith.length--;
		}
	}

	// Make Voting Tokens
	function MakeVotingToken(address _oldAccount, address _voter, string calldata _description) external {
		require(voters.getValuesLength() == numberOfVoters, "Trade partners have not been added to this yet proposal");
		require(!votingtokens[_voter].exists, "This voter already has a voting token");

		VotingTokenPair memory temp;
		temp.token = VotingToken.Token(_description, _oldAccount, _voter, 0, false, false);
		temp.exists = true;
		votingtokens[_voter] = temp;

		VotingTokenCreated++;			// Incroment the number of voting tokens created
	}

	// Add set of data for a give transaction for a give voter
	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, 
		string calldata _description, string calldata _itemsInTrade) external {
		
		require(votingtokens[_voter].exists, "Need to create a voting token for this voter first");
		transactionDataSets[_voter].push(TransactionDataSet.DataSet(_description, _itemsInTrade, oldAccount, _voter, _timeStamp, _amount));
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation( address _voter, uint j) external view returns (uint, uint, address, address) {
		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters
			require(transactionDataSets[voters.getValue(i)].length > 0, "New account has not shared data with all voters yet");
		}
		return transactionDataSets[_voter][j].ViewPublicInformation();
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation( address _voter, uint j) external view returns (string memory, string memory) {
		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters
			require(transactionDataSets[voters.getValue(i)].length > 0, "New account has not shared data with all voters yet");
		}
		return transactionDataSets[_voter][j].ViewPrivateInformation();
	}

	// Casts a vote
	function CastVote(address _voter, bool choice) external {
		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters
			require(transactionDataSets[voters.getValue(i)].length > 0, "New account has not shared data with all voters yet");
		}
		votingtokens[_voter].token.CastVote(choice);
	}

	// Give rewards to voters and return outcome of vote
	function ConcludeAccountRecovery(UserManager UMI) external returns (int){
		require(VotingTokenCreated == voters.getValuesLength(), "Have not created all the VotingTokens");

		if (UMI.getUser(oldAccount).vetoTime() > block.timestamp - startTime){
			return -1;
		}

		uint total = 0;							// Total number of votes
		uint yeses = 0;							// Total number of yesses

		uint totalTimeToVote = 0;

		for (uint i = 0; i < voters.getValuesLength(); i++) { // Goes through all voters
			require(transactionDataSets[voters.getValue(i)].length > 0, "There is no transaction data to view");
			VotingToken.Token storage temp = votingtokens[voters.getValue(i)].token;
			totalTimeToVote += temp.getVotedTime();
			if (temp.getVoted()){				// They are a voter and they voted
				total++;						// Incroment the total number of votes
				if (temp.getVote()){ 			// They are a voter and they voted yes
					yeses++;					// Incroment the number of yesses
				}
			}
		}

		if (total < 5){
			if (block.timestamp - startTime > 172800){
				return 60;
			}
			return -2;
		}

		bool outcome = (100*yeses) / total >= 66;			// The outcome of the vote

		uint participationFactor = 2;
		uint correctionFactor = 2;
		uint timeFactor = 1;

		uint averageTimeToVote = totalTimeToVote / total;

		for (uint i = 0; i < voters.getValuesLength(); i++) { 	// Goes through all voters
			VotingToken.Token storage temp = votingtokens[voters.getValue(i)].token;
			if (temp.getVoted()){							// They are a voter and they voted
				uint amount = (price / participationFactor) / total;			// Reward for participating 

				if (outcome == temp.getVote()){
					if (outcome){
						amount += (price / correctionFactor) / yeses;				// Reward for voting correctly 
					}else{
						amount += (price / correctionFactor) / (total-yeses);		// Reward for voting correctly
					}
				}

				amount += (averageTimeToVote - temp.getVotedTime()) / timeFactor;

				if (amount > 0){
					UMI.getUser(voters.getValue(i)).increaseBalance(amount);	// Increases balance
				}
			}
		}
		return int((100*yeses) / total);										// Return outcome of vote
	}

	// Generate random number using an address
	function random(address address1, uint size) private view returns (uint8) {
		return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, address1, gasleft()))) % size);
		// return uint8(uint256(keccak256(abi.encodePacked(block.difficulty, block.coinbase, address1, gasleft()))) % size);
	}

	function getVoters() external view returns (address[] memory){
		return voters.getValues();
	}

	function ContainsVoter(address _voter) external view returns (bool) {
		return voters.contains(_voter);
	}
}
