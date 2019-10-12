pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

contract Transaction {

	// Public Information
	uint timeStamp;
	Person public sender;
	Person public receiver;
	uint public amount;

	// Private Information

	event Transfer(Person indexed _from, Person indexed _to, uint _value);

	constructor(Person _sender, Person _reciever, uint _amount) public {
		require(_sender.balance() >= _amount, "Invalid Balance.");
		timeStamp = block.timestamp;
		sender = _sender;
		receiver = _reciever;
		amount = _amount;
		sendCoin();
	}

	function sendCoin() internal {
		require(sender.balance() >= amount, "Invalid Balance.");
		sender.decreaseBalance(amount);
		receiver.increaseBalance(amount);
		emit Transfer(sender, receiver, amount);
	}
}	