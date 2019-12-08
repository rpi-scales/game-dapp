/* Transaction.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

/* <Summary> 
	This transaction repersents a transaction on the network
*/

contract Transaction {

	Person sender;				// Sender of the transaction
	Person receiver;			// Reciever of the transacion
	uint timeStamp;				// Time stamp of the transaction
	uint amount;				// Amount of money traded

	// Transaction event
	event Transfer(Person indexed _from, Person indexed _to, uint _value);

	constructor(Person _sender, Person _reciever, uint _amount) public {
		// Requires the sender to have enough money 
		require(_sender.balance() >= _amount, "Invalid Balance.");
		
		// timeStamp = 1;
		// Set Varaiables
		sender = _sender;
		receiver = _reciever;
		timeStamp = block.timestamp;
		amount = _amount;

		// Transfers fund between accounts
		sender.decreaseBalance(amount);			// Decrease the sender's balance
		receiver.increaseBalance(amount);		// Increase the reciever's balance
		emit Transfer(sender, receiver, amount);
	}

	// Returns if a set of data and this tranaction have the same set of public information
	function Equal(uint _timeStamp, address _sender, address _receiver, 
			uint _amount) external view returns (bool){

		// If the given timestamp is within an acceptable range
		bool temp = _timeStamp >= timeStamp - 10 && _timeStamp <= timeStamp + 10;

		// If all the values are the same
		return temp && sender.ID() == _sender && 
			receiver.ID() == _receiver && _amount == amount;
	}

	// Returns the information of the transaction
	function getTransaction() external view returns(address, address, uint) {
		return (sender.ID(), receiver.ID(), amount);
	} 
}	
