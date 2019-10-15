pragma solidity >=0.4.0 <0.7.0;

contract VotingToken {

	struct DataSetInfo {
		// Public Information
		uint timeStamp;
		address sender;
		address receiver;
		uint amount;

		// Private Information
		string description;
		string itemsInTrade;
	}

	bool public exists;

	string description;
	address oldAccount;
	address voter;

	bool public vote;
	bool public voted;

	DataSetInfo[] transactionDataSets;

	event Vote(address indexed _voter, bool _choice);

	constructor(address _oldAccount, address _voter, string memory _description) public {
		voter = _voter;
		oldAccount = _oldAccount;

		vote = false;
		exists = true;
		voted = false;

		description = _description;
	}

	function CastVote(address from, bool choice) public {
		require(exists == true, "This voter does not exist");
		require(voter == from, "Sent from the wrong voter");

		require(transactionDataSets.length > 0, "There is no transaction data to view");

		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}

	function AddTransactionDataSet(uint _timeStamp, address _voter, uint _amount, string memory _description, string memory itemsInTrade) public {
		require(exists == true, "This voter does not exist");
		transactionDataSets.push(DataSetInfo(_timeStamp, oldAccount, _voter, _amount, _description, itemsInTrade));
	}

	function ViewPublicInformation(uint i) public view returns (uint, uint, address, address) {
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		return (transactionDataSets[i].timeStamp, transactionDataSets[i].amount, transactionDataSets[i].sender, transactionDataSets[i].receiver );
	}
	
	function ViewPrivateInformation(uint i) public view returns (string memory, string memory) {
		require(transactionDataSets.length > 0, "There is no transaction data to view");
		return (transactionDataSets[i].description, transactionDataSets[i].itemsInTrade);
	}
}
