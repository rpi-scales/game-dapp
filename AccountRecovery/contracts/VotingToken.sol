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

	address public voter;
	bool public vote;
	bool public voted;

	bool public publicInfo;
	bool public privateInfo;

	// DataSet public dataSet;

	DataSetInfo dataSet;

	event Vote(address indexed _voter, bool _choice);

	constructor(address _voter) public {
		require(_voter != 0x0000000000000000000000000000000000000000, "There is no voter");

		voter = _voter;

		vote = false;
		exists = true;
		voted = false;

		publicInfo = false;
		privateInfo = true;

		dataSet = DataSetInfo(0, 0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, 0, "", "");
	}

	function CastVote(address from, bool choice) public {
		require(exists == true, "This voter does not exist");
		require(voter == from, "Sent from the wrong voter");

		require(publicInfo == true, "No public information");
		require(privateInfo == true, "No private information");

		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}


	function AddPublicInformation(address _oldAccount, uint _timeStamp, uint _amount, address _voter) public {
		require(exists == true, "This voter does not exist");
		require(voter == _voter, "Not the correct voter");

		dataSet.timeStamp = _timeStamp;
		dataSet.amount = _amount;

		dataSet.sender = _oldAccount;
		dataSet.receiver = _voter;

		publicInfo = true;
	}

	function AddPrivateInformation(string memory description, string memory itemsInTrade) public {
		require(exists == true, "This voter does not exist");
		dataSet.description = description;
		dataSet.itemsInTrade = itemsInTrade;
		// dataSet.AddPrivateInformation( description, itemsInTrade );
		privateInfo = true;
	}

	
	function ViewPublicInformation() public view returns (uint, uint, address, address) {
		require(publicInfo == true, "There is no public information to view");
		return (dataSet.timeStamp, dataSet.amount, dataSet.sender, dataSet.receiver );
	}
	

	function ViewPrivateInformation() public view returns (string memory, string memory) {
		require(privateInfo == true, "There is no private information to view");
		return (dataSet.description, dataSet.itemsInTrade);
	}
}
