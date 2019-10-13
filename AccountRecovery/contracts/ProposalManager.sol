pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/TransactionManager.sol";

import "../contracts/Proposal.sol";

contract ProposalManager {

	UserManager UserManagerInstance;
	TransactionManager TransactionManagerInstance;

	address[] voters;
	mapping (address => mapping (address => Proposal[]) ) activeProposals;

	constructor(address UserManagerAddress, address TransactionManagerAddress ) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		TransactionManagerInstance = TransactionManager(TransactionManagerAddress);
	}
	
	function MakeProposal(address oldAccount, address[] memory tradePartners) public {
		require(activeProposals[oldAccount][msg.sender].length == 0, "There already exists a Proposal for this account");

		for (uint i = 0; i < tradePartners.length; i++){
			if (TransactionManagerInstance.getTransactions(oldAccount, tradePartners[i]).length > 0){
				voters.push(tradePartners[i]);
			}
		}

		/*
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
					voters.push(addresses[i]);
				}
			}
		}
		*/
		require(voters.length >= 3, "Invalid Number of transactions");

		// Proposal temp = new Proposal(tradePartners, oldAccount, msg.sender);
		activeProposals[oldAccount][msg.sender].push(new Proposal(voters, oldAccount, msg.sender));

		delete voters;
	}

	function CastVote(address oldAccount, address newAccount, bool choice) public {
		getActiveProposal(oldAccount, newAccount).CastVote(msg.sender, choice);
	}

	function CountVotes(address oldAccount, address newAccount) public {
		getActiveProposal(oldAccount, newAccount).CountVotes(msg.sender);
	}

	function getOutcome(address oldAccount, address newAccount) public view returns(bool) {
		return getActiveProposal(oldAccount, newAccount).getOutcome();
	}

	function getActiveProposal(address oldAccount, address newAccount) public view returns (Proposal) {
		require(activeProposals[oldAccount][newAccount].length == 1, "There is no active Proposal");
		return activeProposals[oldAccount][newAccount][0];
	}

	function MakeVotingToken(address oldAccount, uint timeStamp, uint amount, address _voter) public{
		getActiveProposal(oldAccount, msg.sender).MakeVotingToken(oldAccount, msg.sender, timeStamp, amount, _voter);
	}

	function AddPrivateInformation(address oldAccount, string memory description, string memory itemsInTrade, address _voter) public {
		getActiveProposal(oldAccount, msg.sender).AddPrivateInformation( description, itemsInTrade, _voter);
	}

	function ViewPublicInformation(address oldAccount, address newAccount) public view returns (uint, uint, address, address)  {
		return getActiveProposal(oldAccount, newAccount).ViewPublicInformation( msg.sender );
	}

	function ViewPrivateInformation(address oldAccount, address newAccount) public view returns (string memory, string memory)  {
		return getActiveProposal(oldAccount, newAccount).ViewPrivateInformation( msg.sender );
	}










	/*
	function random(uint8 size) public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%size);
    }
    */

	function GetVotes(address oldAccount, address newAccount) public view returns(uint) {
		return getActiveProposal(oldAccount, newAccount).getVotes();
	}
	function getResult(address oldAccount, address newAccount) public view returns(uint) {
		return getActiveProposal(oldAccount, newAccount).result();
	}
}