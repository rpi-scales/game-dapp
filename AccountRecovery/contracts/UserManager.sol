pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/TransactionManager.sol";

contract UserManager {

	mapping (address => Person) Users;
	address[] addresses;

	constructor(address[] memory _addresses) public {
		for (uint i = 0; i < _addresses.length; i++) {
			Users[_addresses[i]] = new Person(_addresses[i], 1000);
		}
		addresses = _addresses;
	}

	function getUser(address i) public view returns(Person) {
		return Users[i];
	}

	function getAddresses() public view returns(address[] memory) {
		return addresses;
	}

	function getUserBalance(address i) public view returns(uint) {
		return Users[i].balance();
	}

	function getUserID(address i) public view returns(address) {
		return Users[i].ID();
	}
}
