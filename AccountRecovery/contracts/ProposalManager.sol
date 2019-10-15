pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/TransactionManager.sol";

import "../contracts/Proposal.sol";

contract ProposalManager {

	UserManager UserManagerInstance;
	TransactionManager TransactionManagerInstance;

	address[] tradePartners;
	address[] otherPartners;
	address[] haveTradedWith;
	mapping (address => mapping (address => Proposal[]) ) activeProposals;

	constructor(address UserManagerAddress, address TransactionManagerAddress ) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		TransactionManagerInstance = TransactionManager(TransactionManagerAddress);
	}
	
	function MakeProposal(address oldAccount, address[] memory _tradePartners, string memory _description) public {
		require(activeProposals[oldAccount][msg.sender].length == 0, "There already exists a Proposal for this account");

		Person newAccount = UserManagerInstance.getUser(msg.sender);
		uint price = CalculatePrice(oldAccount);

		require(newAccount.balance() >= price, "Not Enough funds for this Proposal");

		newAccount.decreaseBalance(price);

		FindtradePartners(oldAccount, _tradePartners);
		FindOtherAddresses(oldAccount);
		
		require(tradePartners.length >= 3, "Invalid Number of tradePartners");
		require(otherPartners.length >= 3, "Invalid Number of otherPartners");

		activeProposals[oldAccount][msg.sender].push(new Proposal(tradePartners, otherPartners, oldAccount, msg.sender, _description, price));
		delete tradePartners;
		delete otherPartners;
	}

	function FindtradePartners(address oldAccount, address[] memory _tradePartners) internal {
		for (uint i = 0; i < _tradePartners.length; i++){
			if (TransactionManagerInstance.getTransactions(oldAccount, _tradePartners[i]).length > 0){
				tradePartners.push(_tradePartners[i]);
			}
		}
	}

	function FindOtherAddresses(address oldAccount) internal {
		address[] memory addresses = UserManagerInstance.getAddresses();

		for (uint i = 0; i < addresses.length; i++){
			if (TransactionManagerInstance.getTransactions(oldAccount, addresses[i]).length > 0){
				bool exists = false;
				for (uint j = 0; j < tradePartners.length; j++){
					if (addresses[i] == tradePartners[j]){
						exists = true;
					}
				}
				if (exists == false){
					haveTradedWith.push(addresses[i]);
				}
			}
		}

		require(haveTradedWith.length >= 3, "Invalid Number of haveTradedWith");

		uint j = random(0x0000000000000000000000000000000000000000, haveTradedWith.length);
		otherPartners.push(haveTradedWith[j]);
		for (uint i = 1; i < 5; i++){
			j = random(haveTradedWith[i-1], haveTradedWith.length);
			otherPartners.push(haveTradedWith[j]);
		}
	}

	function CalculatePrice(address _oldAccount) internal view returns (uint) {
		Person oldAccount = UserManagerInstance.getUser(_oldAccount);
		uint balance = oldAccount.balance();
		return balance / 20;
	}

	function MakeVotingToken(address oldAccount, address _voter, string memory _description) public {
		getActiveProposal(oldAccount, msg.sender).MakeVotingToken(oldAccount, msg.sender, _voter, _description);
	}

	function MakeTransactionDataSet(address oldAccount, uint timeStamp, uint _amount, address _voter, string memory _description, string memory _itemsInTrade) public {
		Transaction[] memory transaction = TransactionManagerInstance.getTransactions(oldAccount, _voter);

		bool found = false;
		for (uint i = 0; i < transaction.length; i++){
			found = transaction[i].Equal(timeStamp, oldAccount, _voter, _amount);
		}
		require( found == true, "This transaction does not exist");

		getActiveProposal(oldAccount, msg.sender).AddTransactionDataSet(timeStamp, _voter, _amount, _description, _itemsInTrade);
	}

	function ConcludeAccountRecovery(address _oldAccount) public returns (bool){
		if (msg.sender == _oldAccount){
			delete activeProposals[_oldAccount][msg.sender];
			return false;
		}else{
			Person oldAccount = UserManagerInstance.getUser(_oldAccount);
			Person newAccount = UserManagerInstance.getUser(msg.sender);
			if (getActiveProposal(_oldAccount, msg.sender).ConcludeAccountRecovery(UserManagerInstance)){

				newAccount.increaseBalance(oldAccount.balance());
				oldAccount.decreaseBalance(oldAccount.balance());

				delete activeProposals[_oldAccount][msg.sender];
				return true;
			}else{
				delete activeProposals[_oldAccount][msg.sender];
				return false;
			}
		}
	}

	function CastVote(address oldAccount, address newAccount, bool choice) public {
		getActiveProposal(oldAccount, newAccount).CastVote(msg.sender, choice);
	}

	function getActiveProposal(address oldAccount, address newAccount) internal view returns (Proposal) {
		require(activeProposals[oldAccount][newAccount].length == 1, "There is no active Proposal");
		return activeProposals[oldAccount][newAccount][0];
	}

	function ViewPublicInformation(address oldAccount, address newAccount, uint i) public view returns (uint, uint, address, address)  {
		return getActiveProposal(oldAccount, newAccount).ViewPublicInformation( msg.sender, i );
	}

	function ViewPrivateInformation(address oldAccount, address newAccount, uint i) public view returns (string memory, string memory)  {
		return getActiveProposal(oldAccount, newAccount).ViewPrivateInformation( msg.sender, i );
	}

	function random(address address1, uint size) internal view returns (uint8) {
		return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, address1))) % size);
	}
}