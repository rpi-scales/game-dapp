pragma solidity >=0.4.25 <0.6.0;


contract Inventory {

	mapping (address => GameObject) Coins;
	mapping (address => GameObject) Item;

	event Buy(address indexed _buyer, uint256 _price);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		Coins[tx.origin] = new GameObject(10000);
		Item[tx.origin] = new GameObject(0);
	}

	function incrementBalance(address addr, uint amount) external {
		Coins[addr].incrementBalance(amount);
	}

	function buy(uint price) external returns(bool sufficient) {
		if (Coins[msg.sender].getBalance() < price) return false;

		Coins[msg.sender].decrementBalance(price);

		// return G.buy(price);

		Item[msg.sender].incrementBalance(1);
		emit Buy(msg.sender, price);
		return true;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (Coins[msg.sender].getBalance() < amount) return false;

		Coins[msg.sender].decrementBalance(amount);
		Coins[receiver].incrementBalance(amount);
		emit Transfer(msg.sender, receiver, amount);

		return true;
	}


	function getItemBalance(address addr) external view returns (uint) {
		return Item[addr].getBalance();
	}

	function getCoinBalance(address addr) external view returns (uint) {
		return Coins[addr].getBalance();
	}


}

contract GameObject {
	
	uint balance;

	constructor(uint amount) public {
		balance = amount;
	}

	function getBalance() external view returns(uint) {
		return balance;
	}

	function incrementBalance(uint amount) public {
		balance += amount;
	}

	function decrementBalance(uint amount) public {
		balance -= amount;
	}

	function setBalance(uint amount) public {
		balance = amount;
	}
}