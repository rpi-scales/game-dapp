pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

contract Transaction {
	Person public sender;
	Person public receiver;
	uint public amount;

	event Transfer(Person indexed _from, Person indexed _to, uint _value);

	constructor(Person _sender, Person _reciever, uint _amount) public {
		require(_sender.balance() >= _amount, "Invalid Balance.");
		sender = _sender;
		receiver = _reciever;
		amount = _amount;
		sendCoin();
	}

	function sendCoin() internal returns(bool sufficient) {
		sender.decreaseBalance(amount);
		receiver.increaseBalance(amount);
		emit Transfer(sender, receiver, amount);
		return true;
	}
}