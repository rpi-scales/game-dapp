/* UserManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";
import "../contracts/TransactionManager.sol";

/* <Summary> 
	Manages all the users in the network
*/

contract UserManager {

	// A struct containing a user as well as if they are a part of the network
	struct UserPair {
		Person person;
		bool exists;
	}

	mapping (address => UserPair) Users;		// Map of users on the network
	address[] addresses;						// Addresses on the network
	address payable admin;						// Address of the admin

	constructor(address[] memory _addresses) public {
		addresses = _addresses;

		admin = msg.sender;

		// Creates users on the network
		for (uint i = 0; i < addresses.length; i++) {

			// A struct containing a user and if they are a part of the network
			UserPair memory tempPair;
			tempPair.person = new Person(addresses[i], 0, 86400);	// Create account
			tempPair.exists = true;				// They are apart of the network	
			Users[addresses[i]] = tempPair;		// Add them to the map of users
		}
	}

	// Gets the adress of the admin of the network
	function getAdmin() external view returns (address payable) {
		return admin;
	}

	// Gets the user with the given address
	function getUser(address i) public view returns (Person) {
		// Requires that the user is a part of the network
		require(Users[i].exists == true, "This user does not exist");
		return Users[i].person;					// Returns user
	}

	// Gets the list of addresses on the network
	function getAddresses() external view returns (address[] memory) {
		return addresses;
	}
	
	// Gets the balance of a user in the network
	function getUserBalance(address i) external view returns (uint) {
		return getUser(i).balance();
	}

	// Changes the time desinated for this address to veto a malicious proposal
	function changeVetoTime(uint _time) external {
		getUser(msg.sender).setVetoTime(_time);
	}
}
