/* ProposalCreator.sol */

pragma solidity >=0.4.0 <0.7.0;

import "../contracts/UserManager.sol";
import "../contracts/ProposalManager.sol";

/* <Summary> 
	This contract is used by an account to create an account recovery 
	 proposal. All functions in this contract are used by the new new account.
*/

contract ProposalCreator {
	UserManager UMI;			// Connects to the list of users on the network
	TransactionManager TMI;		// Connects to the list of transaction data
	ProposalManager PMI;		// Connects to the list of proposals

	// Used to originally deploy the contract
	constructor(address _UM, address _TM, address _PM) public {
		UMI = UserManager(_UM);
		TMI = TransactionManager(_TM);
		PMI = ProposalManager(_PM);
	}
	
	// Used to create a new account recovery proposal
	function StartProposal(address _oldAccount) external {

		// Checks if there is already an active proposal for this account
		PMI.validProposal(_oldAccount, msg.sender);

		// Price of the account recover proposal: Used to pay voters
		uint price = UMI.getUser(_oldAccount).balance() / 20;

		// Creates Proposal and adds it to the active proposal map
		PMI.AddActiveProposal(_oldAccount, msg.sender, 
			new Proposal(price));
	}

	// Used to view the price of the account recover proposal
	function ViewPrice(address _oldAccount) external view returns (uint) {
		return PMI.getProposal(_oldAccount, msg.sender).price();
	}

	// Used to pay for the account recover proposal
	function Pay(address _oldAccount, bool _pay) external {
		if (_pay){				// The new account is paying for the proposal
			// Finds the person in the network
			Person newAccount = UMI.getUser(msg.sender); 
			// Pays for the proposal
			PMI.getProposal(_oldAccount, msg.sender).Pay(newAccount);
		}
		else{					// The new account will not pay
			PMI.archiveProposal(_oldAccount, msg.sender);	// Deletes proposal
		}
	}

	// Used to add indicated voters to the proposal
	function AddTradePartners(address _oldAccount, address[] calldata _tradePartners) external {

		// Gets voters from past account recovery attempts
		address[] memory archivedVoters = PMI.getArchivedVoter(_oldAccount);

		// Finds proposal and adds indicated voters
		PMI.getProposal(_oldAccount, msg.sender).AddTradePartners( msg.sender, _oldAccount,  
			_tradePartners, archivedVoters, TMI, PMI);
	}

	// Returns a list of voters for an account recovery proposal
	function ViewVoters(address _oldAccount) external view returns (address[] memory) {
		return PMI.getProposal(_oldAccount, msg.sender).getVoters();
	}

	// Randomly selects a trade partner. Also adds the last randomly selected
	//  trade partner to the list of voters
	function RandomTradingPartner(address _oldAccount, bool _veto) external {
		PMI.getProposal(_oldAccount, msg.sender).RandomTradingPartner(_veto);
	}

	// Returns the current randomly selected voter 
	function ViewRandomTradingPartner(address _oldAccount) external view returns (address) {
		return PMI.getProposal(_oldAccount, msg.sender).lastOtherPartner();
	}

	// Checks transaction data and adds it to the proposal to be viewed later
	function MakeTransactionDataSet( address _oldAccount, address _voter, 
			uint _timeStamp, uint _amount, string calldata _description, 
			string calldata _importantNotes, string calldata _location,
			string calldata _itemsInTrade) external {


		// Checks if there exists a transaction with this infromation
		TMI.Equal(_oldAccount, _voter, _timeStamp, _amount);

		Proposal temp = PMI.getProposal(_oldAccount, msg.sender);

		// Checks if this address is actually a voter
		require(temp.ContainsVoter(_voter), "Invalid Voter");
		
		// Adds the tranaction data to the proposal to be viewed by the voter
		temp.AddTransactionDataSet(_voter, _timeStamp, _amount, 
			_description, _importantNotes, _location, _itemsInTrade);
	}
}

/*
require(bytes(_description).length > 0 && 
		bytes(_location).length > 0 && 
		bytes(_itemsInTrade).length > 0, 
		"Must provide private infromation");
*/

// 6471200
// 6568080
// 6530283
// 6096988
// 5939582
// 5762541
// 5677263
// 5643513
// 5807176
