pragma solidity >=0.4.0 <0.7.0;

contract DataSet {
	
	// Public Information
	uint public timeStamp;
	address public sender;
	address public receiver;
	uint public amount;

	// Private Information
	string public description = "description";
	string public itemsInTrade = "itemsInTrade";

	constructor () public {
	}

	function AddPublicInformation(address _sender, uint _timeStamp, uint _amount, address _receiver) public {
		timeStamp = _timeStamp;
		amount = _amount;

		sender = _sender;
		receiver = _receiver;
	}

	function AddPrivateInformation(string memory _description, string memory _itemsInTrade) public {
		description = _description;
		itemsInTrade = _itemsInTrade;
	}
}