/* ProposalManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/Proposal.sol";

import "../contracts/Person.sol";

/* <Summary> 
	This contract manages all active proposal as well as makes and concludes proposals.
*/

contract ProposalManager {

	struct ProposalPair {
		Proposal proposal;
		bool exists;
	}

	UserManager UMI;				// Connects to the list of users on the network

	mapping (address => mapping (address => ProposalPair) ) activeProposals; // Map of active proposals

	mapping (address => address[]) archivedVoters; 	// Map of active proposals
	mapping (address => bool) invalidProposal; 		// If true then there has already been a proposal
	mapping (address => bool) blackListedAccounts; 	// If true then an account is blacklisted

	// Used to originally deploy the contract
	constructor(address UserManagerAddress ) public {
		UMI = UserManager(UserManagerAddress);
	}

	function VetoAccountRecovery(address _newAccount) external{
		getActiveProposal(msg.sender, _newAccount).ConcludeAccountRecovery(UMI);
		archiveProposal(msg.sender, _newAccount);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(address oldAccount, address newAccount, uint i) external view returns (uint, uint, address, address)	{
		Proposal temp = getActiveProposal(oldAccount, newAccount);
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		return temp.ViewPublicInformation( msg.sender, i );
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation(address oldAccount, address newAccount, uint i) external view returns (string memory, string memory) {
		Proposal temp = getActiveProposal(oldAccount, newAccount);
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		return temp.ViewPrivateInformation( msg.sender, i );
	}

	// Allows a voter to cast a vote on a proposal
	function CastVote(address oldAccount, address newAccount, bool choice) external {
		Proposal temp = getActiveProposal(oldAccount, newAccount);
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		temp.CastVote(msg.sender, choice);
	}
	
	// Counts up votes and distriputes the reward
	function ConcludeAccountRecovery(address _oldAccount) external {
		int outcome = getActiveProposal(_oldAccount, msg.sender).ConcludeAccountRecovery(UMI);

		require (outcome != -1, "You must wait more time until you can conclude the vote");
		require (outcome != -2, "Not enough voters have voted yet");

		if (outcome >= 66){											// Successful vote
			// Finds old account and new account on the network
			Person oldAccount = UMI.getUser(_oldAccount);
			Person newAccount = UMI.getUser(msg.sender);

			// Transfers balance
			newAccount.increaseBalance(oldAccount.balance());	// Increase new accounts balance
			oldAccount.decreaseBalance(oldAccount.balance());	// Decrease old accounts balance

		}
		archiveProposal(_oldAccount, msg.sender);

		if (outcome >= 60 && outcome < 66){								// Vote failed. No revote
			invalidProposal[_oldAccount] = false;
		}
	}

	// Find the active proposal between _oldAccount and _newAccount
	function getActiveProposalExists(address _oldAccount, address _newAccount) public view returns (bool) {
		return activeProposals[_oldAccount][_newAccount].exists;
	}
	
	// Find the active proposal between _oldAccount and _newAccount
	function getActiveProposal(address _oldAccount, address _newAccount) public view returns (Proposal) {
		require(getActiveProposalExists(_oldAccount, _newAccount), "There is no active Proposal");
		return activeProposals[_oldAccount][_newAccount].proposal;
	}
	
	// Adds an active proposal between _oldAccount and _newAccount
	function AddActiveProposal(address _oldAccount, address _newAccount, Proposal temp) external {
		invalidProposal[_oldAccount] = true;

		ProposalPair memory tempPair;
		tempPair.proposal = temp;
		tempPair.exists = true;

		activeProposals[_oldAccount][_newAccount] = tempPair;
	}
	
	// Find the archived proposal between _oldAccount and _newAccount
	function getArchivedVoter(address _oldAccount) external view returns (address[] memory) {
		return archivedVoters[_oldAccount];
	}

	function archiveProposal(address _oldAccount, address _newAccount) public {
		Proposal temp = getActiveProposal(_oldAccount, _newAccount);

		address[] memory voters = temp.getVoters();

		for (uint i = 0; i < voters.length; i++){
			archivedVoters[_oldAccount].push(voters[i]);
		}

		delete activeProposals[_oldAccount][_newAccount];
	}

	function validProposal(address _oldAccount) external view returns (bool) {
		require(_oldAccount != UMI.getAdmin(), "Can not try to recover the admin");
		require(_oldAccount != msg.sender, "An account can not recover itself");

		return !invalidProposal[_oldAccount];
	}

	function getBlacklistedAccount(address _address1, address _address2) external view returns (bool) {
		return blackListedAccounts[_address1] || blackListedAccounts[_address2];
	}

	function setBlacklistedAccount(address _address) external {
		blackListedAccounts[_address] = true;
	}
}
