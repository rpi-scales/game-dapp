/* Transaction.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

/* <Summary> 
	This transaction repersents a transaction on the network
*/

contract Transaction {

	uint timeStamp;						// Time stamp of the transaction
	Person sender;				// Sender of the transaction
	Person receiver;				// Reciever of the transacion
	uint amount;					// Amount of money traded

	event Transfer(Person indexed _from, Person indexed _to, uint _value); // Transaction event

	constructor(Person _sender, Person _reciever, uint _amount) public {
		require(_sender.balance() >= _amount, "Invalid Balance.");
		
		timeStamp = 1;
		// timeStamp = block.timestamp;
		sender = _sender;
		receiver = _reciever;
		amount = _amount;
		sendCoin();
	}

	// Send Money
	function sendCoin() internal {
		sender.decreaseBalance(amount);			// Decrease the sender's balance
		receiver.increaseBalance(amount);		// Increase the reciever's balance
		emit Transfer(sender, receiver, amount);
	}

	// Returns if a set of data and this tranaction have the same set of public information
	function Equal(uint _timeStamp, address _sender, address _receiver, uint _amount) external view returns (bool){
		return _timeStamp == timeStamp && sender.ID() == _sender && receiver.ID() == _receiver && _amount == amount;
	}

	function getTransaction() external view returns(address, address, uint) {
		return (sender.ID(), receiver.ID(), amount);
	} 
}	
