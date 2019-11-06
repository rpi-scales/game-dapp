/* UserManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/TransactionManager.sol";

/* <Summary> 
	Manages all the users in the network
*/

contract UserManager {

	struct UserPair {
		Person person;
		bool exists;
	}

	mapping (address => UserPair) Users;					// Map of users on the network
	address[] addresses;								// Addresses on the network
	address payable admin;

	constructor(address[] memory _addresses) public {
		addresses = _addresses;

		admin = msg.sender;

		for (uint i = 0; i < addresses.length; i++) {	// Creates users on the network
			UserPair memory tempPair;
			tempPair.person = new Person(addresses[i], 0, 86400);
			tempPair.exists = true;
			Users[addresses[i]] = tempPair;
		}
	}

	// Gets the adress of the admin of the network
	function getAdmin() external view returns (address payable) {
		return admin;
	}

	// Gets User with the given address
	function getUser(address i) external view returns (Person) {
		require(Users[i].exists == true, "This user does not exist");
		return Users[i].person;
	}

	// Gets the list of addresses on the network
	function getAddresses() external view returns (address[] memory) {
		return addresses;
	}
	
	function getUserBalance(address i) external view returns (uint) {
		require(Users[i].exists == true, "This user does not exist");
		return Users[i].person.balance();
	}

	function changeVetoTime(uint _time) external {
		require(Users[msg.sender].exists == true, "This user does not exist");
		Users[msg.sender].person.setVetoTime(_time);
	}
}
