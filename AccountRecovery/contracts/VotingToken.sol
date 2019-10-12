pragma solidity >=0.4.0 <0.7.0;

import "../contracts/DataSet.sol";

contract VotingToken {

	bool public exists;

	address public voter;
	bool public vote;
	bool public voted;

	bool public publicInfo;
	bool public privateInfo;

	DataSet public dataSet;

	event Vote(address indexed _voter, bool _choice);

	constructor(address _voter) public {
		require(_voter != 0x0000000000000000000000000000000000000000, "There is no voter");

		voter = _voter;

		vote = false;
		exists = true;
		voted = false;

		publicInfo = false;
		privateInfo = true;

		dataSet = new DataSet();

		// require(_voter == 0x0000000000000000000000000000000000000000, "11111");
	}

	function CastVote(address from, bool choice) public {
		require(exists == true, "This voter does not exist");
		require(voter == from, "Sent from the wrong voter");
		require(publicInfo == true && privateInfo == true, "Not an eligible voter");
		require(voted == false, "Already Voted");
		vote = choice;
		voted = true;
		emit Vote(voter, choice);
	}

	function AddPublicInformation(address _oldAccount, uint _timeStamp, uint _amount, address _voter) public {
		require(exists == true, "This voter does not exist");
		require(voter == _voter, "Not the correct voter");
		dataSet.AddPublicInformation(_oldAccount, _timeStamp, _amount, _voter);
		publicInfo = true;
	}

	function AddPrivateInformation(string memory description, string memory itemsInTrade) public {
		require(exists == true, "This voter does not exist");
		dataSet.AddPrivateInformation( description, itemsInTrade );
		privateInfo = true;
	}
	
	function ViewPublicInformation() public view returns (uint, uint, address, address) {
		require(publicInfo == true, "There is no public information to view");
		return (dataSet.timeStamp(), dataSet.amount(), dataSet.sender(), dataSet.receiver() );
	}
	
	function ViewPrivateInformation() public view returns (string memory, string memory) {
		require(privateInfo == true, "There is no private information to view");
		return (dataSet.description(), dataSet.itemsInTrade());
	}
}
