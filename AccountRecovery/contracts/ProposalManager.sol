/* ProposalManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/Proposal.sol";

import "../contracts/Person.sol";

/* <Summary> 
	This contract manages all active proposal. All functions will be called
	 by the voters except for ConcludeProposal which will be called
	 by the new account.
*/

contract ProposalManager {

	// A struct containing the active proposal as well as if it exists
	struct ProposalPair {
		Proposal proposal;			// Active proposal
		bool exists;				// Whether there is an active proposal
	}

	UserManager UMI;				// Connects to the list of users on the network

	// Map of active proposals. activeProposals[oldAccount][newAccount] -> proposal
	mapping (address => mapping (address => ProposalPair) ) activeProposals;

	// Map of voters used in past recovery attempts for that account
	//  Used in case there is a revote
	mapping (address => address[]) archivedVoters; 	

	// A map of if an account can be recovered using an proposal.
	mapping (address => bool) invalidProposal; 

	// A map of blacklisted accounts. These accounts are not allowed to use 
	//  any function on the network 
	mapping (address => bool) blackListedAccounts; 	

	// Used to originally deploy the contract
	constructor(address UserManagerAddress ) public {
		UMI = UserManager(UserManagerAddress);
	}

	// Used by the old account to veto a malicious attempt to steal their account
	function VetoAccountRecovery(address _newAccount, bool attack) external{
		// Pay voters whow have voted
		getProposal(msg.sender, _newAccount).ConcludeProposal(0, UMI);

		// This is needed in case the genuine owner of the old account finds
		//  their private key during the proposal. If they do not then this
		//  must be a malicious attempt and we can blacklist the attacker
		if (attack){								// If it is a malicious attempt
			blackListedAccounts[_newAccount] = true; // Blacklist attacker
		}
		archiveProposal(msg.sender, _newAccount);	// Atchive the proposal
	}

	// View public information of a set of data for a transaction
	function ViewPublicInformation(address _oldAccount, address _newAccount, uint i) 
			external view returns (uint, uint, address, address) {

		Proposal temp = getProposal(_oldAccount, _newAccount); // Finds proposal 
		// Checks if the sender is a voter 
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		return temp.ViewPublicInformation( msg.sender, i ); // Returns information
	}

	// View private information of a set of data for a transaction
	function ViewPrivateInformation(address _oldAccount, address _newAccount, uint i) 
			external view returns (string memory, string memory) {

		Proposal temp = getProposal(_oldAccount, _newAccount); // Finds proposal 
		// Checks if the sender is a voter 
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		return temp.ViewPrivateInformation( msg.sender, i ); // Returns information
	}

	// Allows a voter to cast a vote on a proposal
	function CastVote(address _oldAccount, address _newAccount, bool choice) external {
		Proposal temp = getProposal(_oldAccount, _newAccount); // Finds proposal 
		// Checks if the sender is a voter 
		require(temp.ContainsVoter(msg.sender), "Invalid Voter");
		temp.CastVote(msg.sender, choice);					// Casts vote
	}

	// Counts up votes and distriputes the reward
	function ConcludeProposal(address _oldAccount) external {
		Person oldAccount = UMI.getUser(_oldAccount);
		int outcome = getProposal(_oldAccount, msg.sender).
			ConcludeProposal(oldAccount.vetoTime(), UMI);

		require (outcome != -1, "You must wait more time until you can conclude the vote");
		require (outcome != -2, "Not enough voters have voted yet");

		if (outcome >= 66){										// Successful vote
			// Finds old account and new account on the network
			
			Person newAccount = UMI.getUser(msg.sender);

			// Transfers balance
			newAccount.increaseBalance(oldAccount.balance());	// Increase new account's balance
			oldAccount.decreaseBalance(oldAccount.balance());	// Decrease old account's balance

		}
		archiveProposal(_oldAccount, msg.sender);				// Archive proposal

		if (outcome >= 60 && outcome < 66){						// Revote
			invalidProposal[_oldAccount] = false;				// Allows another vote
		}
	}

	// Finds if there is an active proposal between _oldAccount and _newAccount
	function getActiveProposalExists(address _oldAccount, address _newAccount) 
			public view returns (bool) {
		return activeProposals[_oldAccount][_newAccount].exists;
	}
	
	// Find the active proposal between _oldAccount and _newAccount
	function getProposal(address _oldAccount, address _newAccount) 
			public view returns (Proposal) {

		require(getActiveProposalExists(_oldAccount, _newAccount), 
			"There is no active proposal");
		return activeProposals[_oldAccount][_newAccount].proposal;	// Return proposal
	}
	
	// Adds an active proposal between _oldAccount and _newAccount
	function AddActiveProposal(address _oldAccount, address _newAccount, 
			Proposal temp) external {

		invalidProposal[_oldAccount] = true;	// Can not make another proposal

		// A struct containing the active proposal as well as if it exists
		ProposalPair memory tempPair;
		tempPair.proposal = temp;				// Set proposal
		tempPair.exists = true;					// There is an active proposal
		activeProposals[_oldAccount][_newAccount] = tempPair;
	}

	// Find an archived voters between _oldAccount and _newAccount
	function getArchivedVoter(address _oldAccount) 
			external view returns (address[] memory) {
		return archivedVoters[_oldAccount];		// Return archived voters
	}

	// Remove a proposal from being active. Add voters to archivedVoters
	function archiveProposal(address _oldAccount, address _newAccount) public {
		Proposal temp = getProposal(_oldAccount, _newAccount); // Get proposal

		address[] memory voters = temp.getVoters();			// Get voters

		for (uint i = 0; i < voters.length; i++){			// For each voter
			archivedVoters[_oldAccount].push(voters[i]);	// Add them to archivedVoters
		}

		delete activeProposals[_oldAccount][_newAccount];	// Delete active proposal
	}

	// Determine if a proposal if valid 
	function validProposal(address _oldAccount, address _newAccount) external view {
		require(_oldAccount != UMI.getAdmin(), "Can not try to recover the admin");
		require(_oldAccount != _newAccount, "An account can not recover itself");

		// Checks if the old account account is blacklisted
		require (!blackListedAccounts[_oldAccount], 
			"Once of these accounts are blacklisted");

		// Checks if the new account account is blacklisted
		require (!blackListedAccounts[_newAccount], 
			"Once of these accounts are blacklisted");

		// Checks if there is already an active proposal for this account
		require (!invalidProposal[_oldAccount], 
			"There already exists a proposal for this account");
	}

	// Returns true if the account is blacklisted
	function getBlacklistedAccount(address _address) external view returns (bool) {
		return blackListedAccounts[_address];
	}

	// Blacklists a given account
	function setBlacklistedAccount(address _address) external {
		blackListedAccounts[_address] = true;
	}
}
