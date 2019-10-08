pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/TransactionManager.sol";

import "../contracts/Person.sol";
import "../contracts/VotingToken.sol";

contract ProposalManager {

	UserManager UserManagerInstance;
	TransactionManager TransactionManagerInstance;

	address[] voters;
	mapping (address => mapping (address => VotingToken[]) ) activeTokens;
	// mapping (uint => VotingToken[]) activeTokens;

	constructor(address UserManagerAddress, address TransactionManagerAddress ) public {
		UserManagerInstance = UserManager(UserManagerAddress);
		TransactionManagerInstance = TransactionManager(TransactionManagerAddress);
	}
	
	function MakeProposal(address oldAccount) public {
		require(activeTokens[oldAccount][msg.sender].length == 0, "There already exists a propsal for this account");

		address[] memory addresses = UserManagerInstance.getAddresses();

		for (uint i = 0; i < addresses.length; i++){
			if (TransactionManagerInstance.getTransactions(oldAccount, addresses[i]).length > 0){
				voters.push(addresses[i]);
			}
		}

		require(voters.length >= 3, "Invalid Number of transactions");

		VotingToken temp = new VotingToken(voters, oldAccount, msg.sender);
		activeTokens[oldAccount][msg.sender].push(temp);

		delete voters;
	}

	function CastVote(address oldAccount, address newAccount, bool choice) public {
		getActiveVotingTokens(oldAccount, newAccount).CastVote(choice);
	}

	function GetVotes(address oldAccount, address newAccount) public view returns(uint) {
		return getActiveVotingTokens(oldAccount, newAccount).getVotes();
	}

	function getActiveVotingTokens(address oldAccount, address newAccount) public view returns (VotingToken) {
		require(activeTokens[oldAccount][newAccount].length == 1, "There is no active propsal");
		return activeTokens[oldAccount][newAccount][0];
	}

	function getActiveVotingTokensSender(address oldAccount, address newAccount) public view returns (address) {
		require(activeTokens[oldAccount][newAccount].length == 1, "There is no active propsal");
		return activeTokens[oldAccount][newAccount][0].newAccount();
	}

	/*
	function random(uint8 size) public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%size);
    }
    */
}