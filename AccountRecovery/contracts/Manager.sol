pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/Transaction.sol";

contract Manager {
	mapping (address => Person) Users;
	mapping (address => mapping (address => Transaction[]) ) transactions;

	constructor(address[] memory _addresses) public {
		for (uint i = 0; i < _addresses.length; i++) {
			Users[_addresses[i]] = new Person(_addresses[i], 100);
		}
	}

	function MakeTransaction(address _reciever, uint _amount) public {
		Person sender = Users[msg.sender];
		Person reciever = Users[_reciever];

		/*
		Transaction temp = new Transaction(sender, reciever, _amount);
		if (temp.sendCoin()){
			transactions[sender.ID()][reciever.ID()].push(temp);
		}
		*/
		transactions[sender.ID()][reciever.ID()].push(new Transaction(sender, reciever, _amount));

	}

	function getUserBalance(address i) public view returns(uint) {
		return Users[i].balance();
	}

	function getUserID(address i) public view returns(address) {
		return Users[i].ID();
	}

	function getTransactions(address sender, address receiver, uint i) public view returns(Transaction) {
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index.");
		return transactions[sender][receiver][i];
	}

	function getTransactionsJS(address sender, address receiver, uint i) public view returns(address, address, uint) {
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index.");
		Transaction temp = transactions[sender][receiver][i];
		return (temp.sender().ID(), temp.receiver().ID(), temp.amount());
	}
}