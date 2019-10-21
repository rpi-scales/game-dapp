/* ProposalCreator.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/TransactionManager.sol";
import "../contracts/ProposalManager.sol";

import "../contracts/Proposal.sol";

import "../contracts/Set.sol";

/* <Summary> 
	This contract manages all active proposal as well as makes and concludes proposals.
*/

contract ProposalCreator {
	using Set for Set.Data;

	UserManager UserManagerInstance;				// Connects to the list of users on the network
	TransactionManager TransactionManagerInstance;	// Connects to the transaction data on the network
	ProposalManager PMI;	// Connects to the transaction data on the network

	// These arrays are used when creating Proposals. Needed to be on storage to use .push()
	Set.Data tradePartners;							// List of trade partners indicated by the new account
	address[] haveTradedWith;

	// Used to originally deploy the contract
	constructor(address UserManagerAddress, address TransactionManagerAddress, address ProposalManagerAddress) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		TransactionManagerInstance = TransactionManager(TransactionManagerAddress);
		PMI = ProposalManager(ProposalManagerAddress);
	}
	
	function StartProposal(address _oldAccount, string calldata _description) external returns (uint) {
		require(_oldAccount != msg.sender, "An account can not recover itself");
		// require(!PMI.ActiveProposalLength(_oldAccount, msg.sender), "There already exists a Proposal for this account");
		// require(!PMI.ArchivedProposalLength(_oldAccount, msg.sender), "You have already failed a vote for this recovery");

		uint price = CalculatePrice(_oldAccount);			// Calculates the price of the account recovery

		// Creates Proposal and adds it to the active proposal map
		Proposal temp = new Proposal(_oldAccount, msg.sender, _description, price);

		PMI.AddActiveProposal(_oldAccount, msg.sender, temp);		// Deletes proposal
		return price;
	}

	function Pay(address _oldAccount, bool _pay) external {
		if (_pay){
			Person newAccount = UserManagerInstance.getUser(msg.sender); // Finds the person in the network
			PMI.getActiveProposal(_oldAccount, msg.sender).Pay(newAccount);
		}else{
			PMI.RemoveActiveProposal(_oldAccount, msg.sender);		// Deletes proposal
		}
	}

	function AddTradePartners(address _oldAccount, address[] calldata _tradePartners) external returns(address[] memory){

		FindtradePartners(_oldAccount, msg.sender, _tradePartners); // Checks if indicated partners have transactions 		
		require(tradePartners.getValuesLength() >= 3, "Invalid Number of tradePartners");

		// address[] memory haveTradedWith = FindOtherAddresses(_oldAccount, msg.sender);			// Finds other trade partners to quiz

		FindOtherAddresses(_oldAccount, msg.sender);			// Finds other trade partners to quiz

		// Creates Proposal and adds it to the active proposal map
		PMI.getActiveProposal(_oldAccount, msg.sender).AddTradePartners(tradePartners.getValues(), haveTradedWith);

		delete tradePartners;
		delete haveTradedWith;
	}

	function FindRandomTradingPartner(address _oldAccount) external {
		PMI.getActiveProposal(_oldAccount, msg.sender).FindRandomTradingPartner();
	}
	
	function AddRandomTradingPartner(address _oldAccount, bool choice) external {
		if (choice){
			PMI.getActiveProposal(_oldAccount, msg.sender).AddRandomTradingPartner();
		}
	}

	// Checks if indicated trade partners actually have transactions with the old account
	function FindtradePartners(address oldAccount, address newAccount, address[] memory _tradePartners) private {
		for (uint i = 0; i < _tradePartners.length; i++){	// For each partner
			if (newAccount != _tradePartners[i]){			// The new account can not be a voter
				// They have made a transaction with the old account
				if (TransactionManagerInstance.getTransactions(oldAccount, _tradePartners[i]).length > 0){
					tradePartners.insert(_tradePartners[i]);
				}
			}
		}
	}

		// Finds other trade partners that are used to quiz the new account. These are random
	function FindOtherAddresses(address oldAccount, address newAccount) private {
		address[] memory addresses = UserManagerInstance.getAddresses(); // List of addresses on the network

		for (uint i = 0; i < addresses.length; i++){					// For each address
			if (newAccount != addresses[i]){							// The new account can not be a voter
				// They have made a transaction with the old account
				if (TransactionManagerInstance.getTransactions(oldAccount, addresses[i]).length > 0){
					if (!tradePartners.contains(addresses[i])){			// This address is not already a voter
						haveTradedWith.push(addresses[i]);				// This address is an eligible voter
					}
				}
			}
		}
		require(haveTradedWith.length >= 3, "Invalid Number of haveTradedWith");
	}

	// Calculates the price of recovering an account
	function CalculatePrice(address _oldAccount) internal view returns (uint) {
		uint balance = UserManagerInstance.getUser(_oldAccount).balance();
		return balance / 20;						// 5% of the old account's balance
	}

	// Finds proposal and makes voting token for a specified voter
	function MakeVotingToken(address oldAccount, address _voter, string calldata _description) external {
		PMI.getActiveProposal(oldAccount, msg.sender).MakeVotingToken(oldAccount, _voter, _description);
	}

	// Makes a set of data for a transaction of one of the trade partners. Checks this data 
	function MakeTransactionDataSet(address oldAccount, uint timeStamp, uint _amount, address _voter, 
		string calldata _description, string calldata _itemsInTrade) external {

		require( TransactionManagerInstance.Equal(oldAccount, _voter, timeStamp, _amount), "This transaction does not exist");

		// Finds proposal and creates set of data 
		PMI.getActiveProposal(oldAccount, msg.sender).AddTransactionDataSet(timeStamp, _voter, _amount, _description, _itemsInTrade);
	}
}
