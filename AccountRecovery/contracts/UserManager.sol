/* UserManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/TransactionManager.sol";

/* <Summary> 
	Manages all the users in the network
*/

contract UserManager {

	mapping (address => Person) Users;					// Map of users on the network
	address[] addresses;								// Addresses on the network

	constructor(address[] memory _addresses) public {
		addresses = _addresses;
		for (uint i = 0; i < addresses.length; i++) {	// Creates users on the network
			Users[addresses[i]] = new Person(addresses[i], 1000);
		}
	}

	// Gets User with the given address
	function getUser(address i) public view returns(Person) {
		return Users[i];
	}

	// Gets the list of addresses on the network
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
