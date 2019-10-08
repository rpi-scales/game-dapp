pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/Person.sol";
import "../contracts/Transaction.sol";

contract TransactionManager {
	mapping (address => mapping (address => Transaction[]) ) transactions;
	UserManager UserManagerInstance;

	constructor(address UserManagerAddress) public {
		UserManagerInstance = UserManager(UserManagerAddress);
	}

	function MakeTransaction(address _reciever, uint _amount) public {
		Person sender = UserManagerInstance.getUser(msg.sender);
		Person reciever = UserManagerInstance.getUser(_reciever);

		transactions[msg.sender][_reciever].push(new Transaction(sender, reciever, _amount));
	}

	function getTransactions(address sender, address receiver) public view returns(Transaction[] memory) {
		return transactions[sender][receiver];
	}

	function getTransactionJS(address sender, address receiver, uint i) public view returns(address, address, uint) {
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index");
		Transaction temp = transactions[sender][receiver][i];
		return (temp.sender().ID(), temp.receiver().ID(), temp.amount());
	}
}
