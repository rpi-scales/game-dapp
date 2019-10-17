/* Set.sol */

pragma solidity >=0.4.0 <0.7.0;

library Set {
	struct Data {
		mapping(address => bool) exists;
		address[] values;
	}
	
	function insert(Data storage self, address value) public returns (bool){
		if (self.exists[value]) return false;
		self.exists[value] = true;
		self.values.push(value);
		return true;
	}

	function contains(Data storage self, address value) public view returns (bool) {
		return self.exists[value];
	}

	function getValues(Data storage self) public view returns (address[] memory) {
		return self.values;
	}

	function getValue(Data storage self, uint i) public view returns (address) {
		return self.values[i];
	}

	function getValuesLength(Data storage self) public view returns (uint) {
		return self.values.length;
	}
}