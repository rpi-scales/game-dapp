/* VotingToken.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This contract repersents a voting token. This is used to cast votes and view transaction data.
*/

contract VotingToken {

	struct DataSetInfo {
		// Private Information
		string description;					// Description of transaction
		string itemsInTrade;				// Items in transaction

		// Public Information
		address sender;						// Sender of transaction
		address receiver;					// Reciever of transaction

		uint timeStamp;						// Time stamp of transaction
		uint amount;						// Amount of transaction
	}

	DataSetInfo[] transactionDataSets;		// Sets of data for transactions

	string description;						// Description of the transaction between these addresses
	address oldAccount;						// Address of the old account
	address voter;							// Address of the voter

	bool public vote = false;								// The decision of the voter
	bool public voted = false;								// If the voter has voted

	event Vote(address indexed _voter, bool _choice); // Voting Event

	constructor(address _oldAccount, address _voter, string memory _description) public {
		voter = _voter;
		oldAccount = _oldAccount;
		description = _description;
	}

	// Casting a vote
	function CastVote(bool choice) external {
		// Checks if the voter is allowed to vote
		// require(voter == from, "Sent from the wrong voter");
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}

	// Add a data set for a transaction with this voter
	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, 
		string calldata _description, string calldata _itemsInTrade) external {

		transactionDataSets.push(DataSetInfo(_description, _itemsInTrade, oldAccount, _voter, _timeStamp, _amount));
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
}
