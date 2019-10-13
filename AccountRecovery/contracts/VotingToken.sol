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

	address voter;
	bool public vote;
	bool public voted;

	bool privateInfo;

	DataSetInfo transactionDataSets;

	event Vote(address indexed _voter, bool _choice);

	constructor(address _oldAccount, uint _timeStamp, uint _amount, address _voter) public {
		voter = _voter;

		vote = false;
		exists = true;
		voted = false;

		privateInfo = false;

		transactionDataSets = DataSetInfo(_timeStamp, _oldAccount, _voter, _amount, "", "");
	}

	function CastVote(address from, bool choice) public {
		require(exists == true, "This voter does not exist");
		require(voter == from, "Sent from the wrong voter");

		require(privateInfo == true, "No private information");

		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}

	function AddPrivateInformation(string memory description, string memory itemsInTrade) public {
		require(exists == true, "This voter does not exist");
		transactionDataSets.description = description;
		transactionDataSets.itemsInTrade = itemsInTrade;
		privateInfo = true;
	}

	
	function ViewPublicInformation() public view returns (uint, uint, address, address) {
		return (transactionDataSets.timeStamp, transactionDataSets.amount, transactionDataSets.sender, transactionDataSets.receiver );
	}
	

	function ViewPrivateInformation() public view returns (string memory, string memory) {
		require(privateInfo == true, "There is no private information to view");
		return (transactionDataSets.description, transactionDataSets.itemsInTrade);
	}
}
