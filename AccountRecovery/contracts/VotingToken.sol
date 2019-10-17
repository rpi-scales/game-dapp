/* VotingToken.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This contract repersents a voting token. This is used to cast votes and view transaction data.
*/

contract VotingToken {

	struct DataSetInfo {
		// Public Information
		uint timeStamp;						// Time stamp of transaction
		address sender;						// Sender of transaction
		address receiver;					// Reciever of transaction
		uint amount;						// Amount of transaction

		// Private Information
		string description;					// Description of transaction
		string itemsInTrade;				// Items in transaction
	}

	bool public exists;							// Used to determine if a token exists in a map

	string description;						// Description of the transaction between these addresses
	address oldAccount;						// Address of the old account
	address voter;							// Address of the voter

	bool vote;								// The decision of the voter
	bool voted;								// If the voter has voted

	DataSetInfo[] transactionDataSets;		// Sets of data for transactions

	event Vote(address indexed _voter, bool _choice); // Voting Event

	constructor(address _oldAccount, address _voter, string memory _description) public {
		voter = _voter;
		oldAccount = _oldAccount;

		vote = false;
		exists = true;
		voted = false;

		description = _description;
	}

	// Casting a vote
	function CastVote(address from, bool choice) external {
		// Checks if the voter is allowed to vote
		require(exists == true, "This voter does not exist");
		require(voter == from, "Sent from the wrong voter");
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}

	// Add a data set for a transaction with this voter
	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, 
		string calldata _description, string calldata itemsInTrade) external {

		require(exists == true, "This voter does not exist");
		transactionDataSets.push(DataSetInfo(_timeStamp, oldAccount, _voter, 
			_amount, _description, itemsInTrade));
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(uint i) external view returns (uint, uint, address, address) {
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		return (transactionDataSets[i].timeStamp, transactionDataSets[i].amount, transactionDataSets[i].sender, transactionDataSets[i].receiver );
	}
	
	// View private information on a set of data for a transaction
	function ViewPrivateInformation(uint i) external view returns (string memory, string memory) {
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		return (transactionDataSets[i].description, transactionDataSets[i].itemsInTrade);
	}

	// The voter is eligible to vote and has voted
	function ExistsAndVoted() external view returns (bool){
		return exists && voted;
	}

	// The voter is eligible to vote and voted yes
	function VotedYes() external view returns (bool) {
		return exists && voted && vote;
	}
}
