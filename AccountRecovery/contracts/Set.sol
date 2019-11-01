/* Set.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/Person.sol";

library Set {
	struct AddressData {
		mapping(address => bool) exists;
		address[] values;
	}
	
	function insert(AddressData storage self, address value) external {
		if (self.exists[value]) return;
		self.exists[value] = true;
		self.values.push(value);
	}

	function contains(AddressData storage self, address value) external view returns (bool) {
		return self.exists[value];
	}

	function getValues(AddressData storage self) external view returns (address[] memory) {
		return self.values;
	}

	function getValue(AddressData storage self, uint i) external view returns (address) {
		return self.values[i];
	}

	function getValuesLength(AddressData storage self) external view returns (uint) {
		return self.values.length;
	}
	/*

	struct PersonData {
		mapping(address => bool) exists;
		mapping(address => Person) values;
	}

	function insert(PersonData storage self, Person value) external {
		if (self.exists[value.ID()]) return;
		self.exists[value.ID()] = true;
		self.values[value.ID()] = value;
	}

	function contains(PersonData storage self, address value) external view returns (bool) {
		return self.exists[value];
	}

	function getValue(PersonData storage self, address i) external view returns (Person) {
		return self.values[i];
	}
	*/


}