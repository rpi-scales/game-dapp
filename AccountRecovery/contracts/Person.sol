pragma solidity >=0.4.0 <0.7.0;

contract Person {
	address public ID;
	uint public balance;

	constructor(address _ID, uint _balance) public {
		ID = _ID;
		balance = _balance;
	}

	function increaseBalance(uint amount) public {
		balance += amount;
	}

	function decreaseBalance(uint amount) public {
		balance -= amount;
	}
}