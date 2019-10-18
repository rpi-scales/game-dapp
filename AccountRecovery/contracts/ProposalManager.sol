/* ProposalManager.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/Proposal.sol";


/* <Summary> 
	This contract manages all active proposal as well as makes and concludes proposals.
*/

contract ProposalManager {
	UserManager UserManagerInstance;				// Connects to the list of users on the network

	// These arrays are used when creating Proposals. Needed to be on storage to use .push()

	mapping (address => mapping (address => Proposal[]) ) activeProposals; // Map of active proposals
													// Old Account -> New Account -> Proposal

	// Used to originally deploy the contract
	constructor(address UserManagerAddress ) public {
		UserManagerInstance = UserManager(UserManagerAddress);
	}
	
	// Counts up votes and distriputes the reward
	function ConcludeAccountRecovery(address _oldAccount) public returns (bool){
		if (msg.sender == _oldAccount){				// Veto from the old account
			delete activeProposals[_oldAccount][msg.sender]; // Deletes proposal
			return false;
		}else{										// The msg.sender == new account

			// Checks outcome of vote
			if (getActiveProposal(_oldAccount, msg.sender).ConcludeAccountRecovery(UserManagerInstance)){

				// Finds old account and new account on the network
				Person oldAccount = UserManagerInstance.getUser(_oldAccount);
				Person newAccount = UserManagerInstance.getUser(msg.sender);

				// Transfers balance
				newAccount.increaseBalance(oldAccount.balance());
				oldAccount.decreaseBalance(oldAccount.balance());

				delete activeProposals[_oldAccount][msg.sender]; // Deletes proposal
				return true;
			}else{
				delete activeProposals[_oldAccount][msg.sender]; // Deletes proposal
				return false;
			}
		}
	}

	// Allows a voter to cast a vote on a proposal
	function CastVote(address oldAccount, address newAccount, bool choice) public {
		getActiveProposal(oldAccount, newAccount).CastVote(msg.sender, choice);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(address oldAccount, address newAccount, uint i) public view returns (uint, uint, address, address)	{
		return getActiveProposal(oldAccount, newAccount).ViewPublicInformation( msg.sender, i );
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation(address oldAccount, address newAccount, uint i) public view returns (string memory, string memory)	{
		return getActiveProposal(oldAccount, newAccount).ViewPrivateInformation( msg.sender, i );
	}
		// Find the active proposal between _oldAccount and _newAccount
	function getActiveProposal(address _oldAccount, address _newAccount) public view returns (Proposal) {
		require(activeProposals[_oldAccount][_newAccount].length == 1, "There is no active Proposal");
		return activeProposals[_oldAccount][_newAccount][0];
	}
		// Find the active proposal between _oldAccount and _newAccount
	function AddActiveProposal(address _oldAccount, address _newAccount, Proposal temp) public {
		require(activeProposals[_oldAccount][_newAccount].length == 0, "There is already an active Proposal");
		activeProposals[_oldAccount][_newAccount].push(temp);
	}
		// Find the active proposal between _oldAccount and _newAccount
	function RemoveActiveProposal(address _oldAccount, address _newAccount) public {
		require(activeProposals[_oldAccount][_newAccount].length == 1, "There is no active Proposal");
		delete activeProposals[_oldAccount][_newAccount];
	}
}
