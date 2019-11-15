/* TransactionDataSet.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This library repersents transaction data. This is by the voter to decide
	 if the new account is the genuine owner of the old account.
*/

library TransactionDataSet {

	// A struct containing the private and the public information
	struct DataSet {
		// Private Information
		string description;					// Description of transaction
		string location;					// Location of the transaction
		string itemsInTrade;				// Items in the transaction

		// Public Information
		address sender;						// Sender of transaction
		address receiver;					// Reciever of transaction
		uint timeStamp;						// Time stamp of transaction
		uint amount;						// Amount of transaction
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(DataSet storage self) 
			external view returns (uint, uint, address, address) {

		// Returns public information
		return (self.timeStamp, self.amount, self.sender, self.receiver );
	}
	
	// View private information on a set of data for a transaction
	function ViewPrivateInformation(DataSet storage self) external view 
		returns (string memory, string memory, string memory) {

		// Returns private information
		return (self.description, self.location, self.itemsInTrade);
	}
}
