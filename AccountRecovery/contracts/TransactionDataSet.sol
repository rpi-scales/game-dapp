/* TransactionDataSet.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	


	
*/

library TransactionDataSet {
	struct DataSet {
		// Private Information
		string description;					// Description of transaction
		string itemsInTrade;				// Items in transaction

		// Public Information
		address sender;						// Sender of transaction
		address receiver;					// Reciever of transaction

		uint timeStamp;						// Time stamp of transaction
		uint amount;						// Amount of transaction
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(DataSet storage self) external view returns (uint, uint, address, address) {
		return (self.timeStamp, self.amount, self.sender, self.receiver );
	}
	
	// View private information on a set of data for a transaction
	function ViewPrivateInformation(DataSet storage self) external view returns (string memory, string memory) {
		return (self.description, self.itemsInTrade);
	}
}
