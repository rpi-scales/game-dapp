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
	mapping (address => mapping (address => bool[]) ) archivedProposalsResults; // Map of active proposals
													// Old Account -> New Account -> Proposal[]

	// Used to originally deploy the contract
	constructor(address UserManagerAddress ) public {
		UserManagerInstance = UserManager(UserManagerAddress);
	}

	function ViewRandomTradingPartner(address _oldAccount) external view returns (address) {
		return getActiveProposal(_oldAccount, msg.sender).ViewRandomTradingPartner();
	}

	function VetoAccountRecovery(address _newAccount) external{
		RemoveActiveProposal(msg.sender, _newAccount);
	}
	
	// Counts up votes and distriputes the reward
	function ConcludeAccountRecovery(address _oldAccount) external {
		Proposal temp = getActiveProposal(_oldAccount, msg.sender);
		RemoveActiveProposal(_oldAccount, msg.sender);	// Deletes proposal

		(bool outcome, bool revote)  = temp.ConcludeAccountRecovery(UserManagerInstance);

		if (outcome){											// Successful vote
			// Finds old account and new account on the network
			Person oldAccount = UserManagerInstance.getUser(_oldAccount);
			Person newAccount = UserManagerInstance.getUser(msg.sender);

			// Transfers balance
			newAccount.increaseBalance(oldAccount.balance());	// Increase new accounts balance
			oldAccount.decreaseBalance(oldAccount.balance());	// Decrease old accounts balance
			
			AddArchivedProposal(_oldAccount, msg.sender, outcome);

		}else if (!revote){									// Requires a re-vote
			AddArchivedProposal(_oldAccount, msg.sender, outcome);
		}
	}

	// Allows a voter to cast a vote on a proposal
	function CastVote(address oldAccount, address newAccount, bool choice) external {
		getActiveProposal(oldAccount, newAccount).CastVote(msg.sender, choice);
	}

	// View public information on a set of data for a transaction
	function ViewPublicInformation(address oldAccount, address newAccount, uint i) external view returns (uint, uint, address, address)	{
		return getActiveProposal(oldAccount, newAccount).ViewPublicInformation( msg.sender, i );
	}

	// View private information on a set of data for a transaction
	function ViewPrivateInformation(address oldAccount, address newAccount, uint i) external view returns (string memory, string memory)	{
		return getActiveProposal(oldAccount, newAccount).ViewPrivateInformation( msg.sender, i );
	}
	
	// Find the active proposal between _oldAccount and _newAccount
	function getActiveProposal(address _oldAccount, address _newAccount) public view returns (Proposal) {
		require(activeProposals[_oldAccount][_newAccount].length == 1, "There is no active Proposal");
		return activeProposals[_oldAccount][_newAccount][0];
	}

	// Finds if there is an active Proposal between _oldAccount and _newAccount
	function ActiveProposalLength(address _oldAccount, address _newAccount) external view returns (bool) {
		return activeProposals[_oldAccount][_newAccount].length == 1;
	}
	
	// Adds an active proposal between _oldAccount and _newAccount
	function AddActiveProposal(address _oldAccount, address _newAccount, Proposal temp) external {
		require(activeProposals[_oldAccount][_newAccount].length == 0, "There is already an active Proposal");
		activeProposals[_oldAccount][_newAccount].push(temp);
	}
	
	// Removes the active proposal between _oldAccount and _newAccount
	function RemoveActiveProposal(address _oldAccount, address _newAccount) public {
		require(activeProposals[_oldAccount][_newAccount].length == 1, "There is no active Proposal");
		delete activeProposals[_oldAccount][_newAccount];
	}

	// Find the archived proposal between _oldAccount and _newAccount
	function getArchivedProposals(address _oldAccount, address _newAccount) external view returns (bool[] memory) {
		require(archivedProposalsResults[_oldAccount][_newAccount].length > 0, "There is no archived Proposal");
		return archivedProposalsResults[_oldAccount][_newAccount];
	}

	// Finds if there is an archived Proposal between _oldAccount and _newAccount
	function ArchivedProposalLength(address _oldAccount, address _newAccount) external view returns (bool) {
		return archivedProposalsResults[_oldAccount][_newAccount].length == 1;
	}

	// Adds an archived proposal between _oldAccount and _newAccount
	function AddArchivedProposal(address _oldAccount, address _newAccount, bool temp) private {
		archivedProposalsResults[_oldAccount][_newAccount].push(temp);
	}
}
