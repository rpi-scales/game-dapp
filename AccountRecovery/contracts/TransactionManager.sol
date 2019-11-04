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
	mapping (address => mapping (address => Transaction[]) ) transactions;
	UserManager UserManagerInstance;			// Connects to the list of users on the network
	ProposalManager PMI;	// Connects to the list of active proposals on the network

	constructor(address UserManagerAddress, address ProposalManagerAddress) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		PMI = ProposalManager(ProposalManagerAddress);
	}

	function BuyCoin() public payable {
		address payable admin = UserManagerInstance.getAdmin();
		admin.transfer(msg.value);								// Spend ETH

		Person buyer = UserManagerInstance.getUser(msg.sender); // Finds buy
		uint price = msg.value/10000000000000000;				// 1 ETh = 100 Coins
		buyer.increaseBalance(price);							// Increase the reciever's balance

	}

	// Makes a transaction between 2 users
	function MakeTransaction(address _reciever, uint _amount) external {
		require (_reciever != msg.sender, "Can not send money to yourself");
		require (_reciever != address(UserManagerInstance.getAdmin()), "Can not send money to the admin");
		require (!CheckForBribery(msg.sender, _reciever), "This is Bribery");

		address newAccount = CheckForOldAccount(msg.sender);
		while (newAccount != 0x0000000000000000000000000000000000000000){
			PMI.archiveProposal(msg.sender, newAccount);
			newAccount = CheckForOldAccount(msg.sender);
		}
		Person sender = UserManagerInstance.getUser(msg.sender); // Finds sender
		Person reciever = UserManagerInstance.getUser(_reciever); // Finds reciever

		// Makes transaction 
		transactions[msg.sender][_reciever].push(new Transaction(sender, reciever, _amount));
	}

	// Gets transacions between 2 addresses
	function getTransactions(address sender, address receiver) external view returns(Transaction[] memory) {
		return transactions[sender][receiver];
	}

	// Gets the number of transacions between 2 addresses
	function NumberOfTransactions(address sender, address receiver) external view returns(uint) {
		return transactions[sender][receiver].length;
	}

	// Get a transaction between 2 address but returns it in parts
	function getTransactionJS(address sender, address receiver, uint i) external view returns(address, address, uint) {
		require(i < transactions[sender][receiver].length && i >= 0, "Invalid Index");
		return transactions[sender][receiver][i].getTransaction();
	}

	function Equal(address sender, address receiver, uint timeStamp, uint _amount) external view returns (bool) {
		Transaction[] storage temp = transactions[sender][receiver];

		for (uint i = 0; i < temp.length; i++){
			if (temp[i].Equal(timeStamp, sender, receiver, _amount)){
				return true;
			}
		}
		return false;
	}

	function CheckForOldAccount(address _oldAccount) internal view returns (address){
		address[] memory addresses = UserManagerInstance.getAddresses(); // List of addresses on the network
		for (uint i = 0; i < addresses.length; i++){					// For each address
			if (_oldAccount != addresses[i]){							// The new account can not be a voter
				if (PMI.getActiveProposalExists(_oldAccount, addresses[i])){
					return addresses[i];
				}
			}
		}
		return 0x0000000000000000000000000000000000000000;
	}

	function CheckForBribery(address _newAccount, address _voter) internal view returns (bool){
		address[] memory addresses = UserManagerInstance.getAddresses(); // List of addresses on the network

		for (uint i = 0; i < addresses.length; i++){					// For each address
			if (_newAccount != addresses[i]){							// The new account can not be a voter
				if (PMI.getActiveProposalExists(addresses[i], _newAccount)){
					Proposal temp = PMI.getActiveProposal(addresses[i], _newAccount);
					address[] memory voters = temp.getVoters();
					for(uint j = 0; j < voters.length; j++){
						if (voters[j] == _voter){
							return true;
						}
					}
				}
			}
		}
		return false;
	}

}
