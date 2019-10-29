/* ProposalCreator.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/TransactionManager.sol";
import "../contracts/ProposalManager.sol";

import "../contracts/Proposal.sol";

/* <Summary> 
	This contract manages all active proposal as well as makes and concludes proposals.
*/

contract ProposalCreator {
	UserManager UserManagerInstance;				// Connects to the list of users on the network
	TransactionManager TransactionManagerInstance;	// Connects to the transaction data on the network
	ProposalManager PMI;							// Connects to the transaction data on the network

	// These arrays are used when creating Proposals. Needed to be on storage to use .push()

	// Used to originally deploy the contract
	constructor(address UserManagerAddress, address TransactionManagerAddress, address ProposalManagerAddress) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		TransactionManagerInstance = TransactionManager(TransactionManagerAddress);
		PMI = ProposalManager(ProposalManagerAddress);
	}
	
	function StartProposal(address _oldAccount, string calldata _description) external {
		require(_oldAccount != UserManagerInstance.getAdmin(), "Can not try to recover the admin");
		require(_oldAccount != msg.sender, "An account can not recover itself");
		require(!PMI.ActiveProposalLength(_oldAccount, msg.sender), "There already exists a Proposal for this account");
		require(!PMI.ArchivedProposalLength(_oldAccount, msg.sender), "You have already failed a vote for this recovery");

		// uint price = CalculatePrice(_oldAccount);			// Calculates the price of the account recovery

		uint balance = UserManagerInstance.getUser(_oldAccount).balance();
		uint price = balance / 20;

		// Creates Proposal and adds it to the active proposal map
		Proposal temp = new Proposal(_oldAccount, msg.sender, _description, price);

		PMI.AddActiveProposal(_oldAccount, msg.sender, temp);		// Deletes proposal
	}

	function ViewPrice(address _oldAccount) external view returns (uint) {
		return PMI.getActiveProposal(_oldAccount, msg.sender).price();
	}

	function Pay(address _oldAccount, bool _pay) external {
		if (_pay){
			Person newAccount = UserManagerInstance.getUser(msg.sender); // Finds the person in the network
			PMI.getActiveProposal(_oldAccount, msg.sender).Pay(newAccount);
		}else{
			PMI.RemoveActiveProposal(_oldAccount, msg.sender);		// Deletes proposal
		}
	}

	function AddTradePartners(address _oldAccount, address[] calldata _tradePartners) external {
		PMI.getActiveProposal(_oldAccount, msg.sender).AddTradePartners(_tradePartners, UserManagerInstance, TransactionManagerInstance);
	}

	function FindRandomTradingPartner(address _oldAccount) external {
		PMI.getActiveProposal(_oldAccount, msg.sender).FindRandomTradingPartner();
	}

	function ViewRandomTradingPartner(address _oldAccount) external view returns (address) {
		return PMI.getActiveProposal(_oldAccount, msg.sender).ViewRandomTradingPartner();
	}
	
	function AddRandomTradingPartner(address _oldAccount) external {
		PMI.getActiveProposal(_oldAccount, msg.sender).AddRandomTradingPartner();
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

// 6581377
