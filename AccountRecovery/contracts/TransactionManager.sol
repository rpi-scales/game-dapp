/* TransactionManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/ProposalManager.sol";

import "../contracts/Person.sol";
import "../contracts/Transaction.sol";

/* <Summary> 
	Manages the list of transaction as well as making transactions
*/

contract TransactionManager {

	// A map of all transaction on the ledger
	mapping (address => mapping (address => Transaction[]) ) transactions;

	// A array used to return the trade partners of a give account
	address[] haveTradedWith;

	UserManager UMI;		// Connects to the list of users on the network
	ProposalManager PMI;	// Connects to the list of active proposals on the network

	constructor(address UserManagerAddress, address ProposalManagerAddress) public {
		UMI = UserManager(UserManagerAddress);
		PMI = ProposalManager(ProposalManagerAddress);
	}

	// Allows a users to buy coins from the admin
	function BuyCoin() external payable {
		// Requires that the user is not blacklisted
		require (!PMI.getBlacklistedAccount(msg.sender), 
			"The sender is blacklisted");

		Person buyer = UMI.getUser(msg.sender); 		// Finds buyer
		address payable admin = UMI.getAdmin();			// Get admin's address

		admin.transfer(msg.value);						// Send ETH to admin
		uint price = msg.value/10000000000000000;		// 1 ETH = 100 Coins
		buyer.increaseBalance(price);					// Increase the buyer's balance

	}

	// Makes a transaction between 2 users
	function MakeTransaction(address _reciever, uint _amount) external {

		// Requires that the sender is not the reciever
		require (_reciever != msg.sender, "Can not send money to yourself");

		// Requires that the receiver is not the admin
		require (_reciever != address(UMI.getAdmin()), 
			"Can not send money to the admin");

		// Checks if either account is blacklisted
		require (!PMI.getBlacklistedAccount(msg.sender), 
			"The sender is blacklisted");
		require (!PMI.getBlacklistedAccount(_reciever), 
			"The reciever is blacklisted");

		// List of addresses on the network
		address[] memory addresses = UMI.getAddresses(); 

		// Checks if the reciever is a voter for a proposal where the sender 
		//  is the new account. This is bribery  
		require (!CheckForBribery(msg.sender, _reciever, addresses), "This is bribery");

		// Checks if the sender is the old account of any proposals
		//  Finds if there is a proposal and returns the new account
		//  If it returns 0x00.. then there is no more proposals
		address newAccount = CheckForOldAccount(msg.sender, addresses);

		// Until there is no more proposals
		while (newAccount != 0x0000000000000000000000000000000000000000){

			// Deletes proposal
			PMI.archiveProposal(msg.sender, newAccount);

			// Black lists attackers
			PMI.setBlacklistedAccount(newAccount);

			// Finds if there is anymore proposals
			newAccount = CheckForOldAccount(msg.sender, addresses);
		}

		// Finds users on the network
		Person sender = UMI.getUser(msg.sender); // Finds sender
		Person reciever = UMI.getUser(_reciever); // Finds reciever

		// Makes transaction and adds it to the list
		transactions[msg.sender][_reciever].push(
			new Transaction(sender, reciever, _amount));
	}

	// Gets the transactions between 2 addresses
	function getTransactions(address sender, address receiver) 
			external view returns(Transaction[] memory) {
		
		return transactions[sender][receiver];
	}

	// Gets the number of transactions between 2 addresses
	function NumberOfTransactions(address sender, address receiver) 
			public view returns(uint) {

		return transactions[sender][receiver].length;
	}

	// Get a transaction between 2 address but returns it in parts
	function getTransactionJS(address sender, address receiver, uint i) 
			external view returns(address, address, uint) {

		// Requires the index to be valid
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index");
		// Returns parts of transaction
		return transactions[sender][receiver][i].getTransaction();
	}

	// Finds if there is a transaction that consists of information provided
	function Equal(address sender, address receiver, uint timeStamp, 
			uint _amount) external view {

		// Gets the list of transactions
		Transaction[] storage temp = transactions[sender][receiver];

		bool found = false;							// If the transaction has been found

		for (uint i = 0; i < temp.length; i++){		// For each transaction	
			// Compares infromation to the transaction
			if (temp[i].Equal(timeStamp, sender, receiver, _amount)){
				found = true;						// Transaction was found
			}

		}

		// Requires that the transaction was found
		require(found, "This transaction does not exist");
	}

	// Checks if the sender of a transaction is being recovered by a proposal
	function CheckForOldAccount(address _oldAccount, address[] memory addresses) 
			internal view returns (address){

		// Checks if there is proposal with the sender as the old account
		for (uint i = 0; i < addresses.length; i++){
			// If a proposal exists for this sender
			if (PMI.getActiveProposalExists(_oldAccount, addresses[i])){
				return addresses[i];		// Return the address of the attacker
			}
		}
		// If there is no proposal return 0x00...
		return 0x0000000000000000000000000000000000000000;
	}

	// Checks if a new account is sending monet to a voter
	function CheckForBribery(address _newAccount, address _voter, 
			address[] memory addresses) internal returns (bool){

		// Checks if there is proposal with the new account and voter
		for (uint i = 0; i < addresses.length; i++){

			// If a proposal exists
			if (PMI.getActiveProposalExists(addresses[i], _newAccount)){

				// Get proposal
				Proposal temp = PMI.getProposal(addresses[i], _newAccount);
				address[] memory voters = temp.getVoters();		// List of voters
				for(uint j = 0; j < voters.length; j++){
					if (voters[j] == _voter){					// Found the voter

						// Blacklist this voter and reciever
						PMI.setBlacklistedAccount(_voter);
						PMI.setBlacklistedAccount(_newAccount);

						return true;
					}
				}
			}
		}
		return false;
	}

	// Finds the trade partners of a give account
	function getHaveTradedWith(address account) 
			external returns (address[] memory){

		delete haveTradedWith;							// Clears data
		
		// List of addresses on the network
		address[] memory addresses = UMI.getAddresses();

		for (uint i = 0; i < addresses.length; i++){	// For each address
			// Check if they have made a transaction with the old account
			if (NumberOfTransactions(account, addresses[i]) > 0){
				haveTradedWith.push(addresses[i]);
			}
		}
		return haveTradedWith;							// Returns trade partners
	}

}
