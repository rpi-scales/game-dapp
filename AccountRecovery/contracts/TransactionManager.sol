/* TransactionManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/Person.sol";
import "../contracts/Transaction.sol";

/* <Summary> 
	Manages the list of transaction as well as making transactions
*/

contract TransactionManager {
	mapping (address => mapping (address => Transaction[]) ) transactions;
	UserManager UserManagerInstance;			// Connects to the list of users on the network

	constructor(address UserManagerAddress) public {
		UserManagerInstance = UserManager(UserManagerAddress);
	}

	// Makes a transaction between 2 users
	function MakeTransaction(address _reciever, uint _amount) external {
		Person sender = UserManagerInstance.getUser(msg.sender); // Finds sender
		Person reciever = UserManagerInstance.getUser(_reciever); // Finds reciever

		// Makes transaction 
		transactions[msg.sender][_reciever].push(new Transaction(sender, reciever, _amount));
	}

	// Gets transacions between 2 addresses
	function getTransactions(address sender, address receiver) external view returns(Transaction[] memory) {
		return transactions[sender][receiver];
	}

	// Get a transaction between 2 address but returns it in parts
	function getTransactionJS(address sender, address receiver, uint i) external view returns(address, address, uint) {
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index");
		return transactions[sender][receiver][i].getTransaction();
	}
}
