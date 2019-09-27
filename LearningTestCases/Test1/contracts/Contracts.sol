pragma solidity >=0.4.25 <0.6.0;

contract Coin {
	mapping (address => uint) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		balances[tx.origin] = 10000;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;

		decrementBalance(msg.sender, amount);
		incrementBalance(receiver, amount);
		emit Transfer(msg.sender, receiver, amount);

		return true;
	}

	function getBalance(address addr) external view returns(uint) {
		return balances[addr];
	}

	function incrementBalance(address addr, uint amount) public returns(bool sufficient) {
		return setBalance(addr, balances[addr] + amount);
	}

	function decrementBalance(address addr, uint amount) public returns(bool sufficient) {
		return setBalance(addr, balances[addr] - amount);
	}

	function setBalance(address addr, uint amount) public returns(bool sufficient) {
		balances[addr] = amount;
		return true;
	}
}

contract GameObject {
	mapping (address => uint) balances;

	event Buy(address indexed _buyer, uint256 _price);

	constructor() public {
		balances[tx.origin] = 0;
	}

	function buy(uint price) public returns(bool sufficient) {
		// if (C.getBalance(msg.sender) < price) return false;
		// Coin.decrementBalance(msg.sender, price);

		incrementBalance(msg.sender, 1);
		emit Buy(msg.sender, price);

		return true;
	}


	function getBalance(address addr) public view returns(uint) {
		return balances[addr];
	}

	function incrementBalance(address addr, uint amount) public returns(bool sufficient) {
		return setBalance(addr, getBalance(addr) + amount);
	}

	function decrementBalance(address addr, uint amount) public returns(bool sufficient) {
		return setBalance(addr, getBalance(addr) - amount);
	}

	function setBalance(address addr, uint amount) public returns(bool sufficient) {
		balances[addr] = amount;
		return true;
	}

	
}
