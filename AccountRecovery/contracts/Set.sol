/* Set.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This library repersents the set data structure of addresses
*/

library Set {

	// A struct an array of address and a map of if they are in the array
	struct AddressData {
		mapping(address => bool) exists;
		address[] values;
	}

	// Inserts an address into the array
	function insert(AddressData storage self, address value) external {
		if (self.exists[value]) return;		// The address already is in the array
		self.exists[value] = true;			// Updates the map to reflect the array
		self.values.push(value);			// Add the value to the array
	}

	// Returns if a value is already in the set
	function contains(AddressData storage self, address value) 
			external view returns (bool) {

		return self.exists[value];
	}

	// Returns the array of values
	function getValues(AddressData storage self) 
			external view returns (address[] memory) {

		return self.values;
	}

	// Returns a certain value in the array
	function getValue(AddressData storage self, uint i) 
			external view returns (address) {

		return self.values[i];
	}

	// Returns the length of the array of values
	function getValuesLength(AddressData storage self) 
			external view returns (uint) {

		return self.values.length;
	}
}