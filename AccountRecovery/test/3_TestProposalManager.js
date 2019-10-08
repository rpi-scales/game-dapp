const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const ProposalManager = artifacts.require("ProposalManager");
var ProposalManagerInstance;

contract('ProposalManager', (accounts) => {

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
		TransactionManagerInstance = await TransactionManager.deployed(UserManagerInstance.address);
		ProposalManagerInstance = await ProposalManager.deployed(UserManagerInstance.address, TransactionManagerInstance.address);
	});
	
	/*
	it('Make Proposal (New Account: 10, Old Account: 1): Invalid', async () => {
		var newAccount = accounts[9];
		var oldAccount = accounts[0];

		await ProposalManagerInstance.MakeProposal(oldAccount, { from: newAccount });
	});
	*/

	it('Send Money (Account 1 to Account 3,4,5,6,7,8,9): Valid', async () => {
		const sender = accounts[0];

		const amount = 10;
		for (i = 2; i < 8; i++) {
			const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			await TransactionManagerInstance.MakeTransaction(accounts[i], amount, { from: sender });
			const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		}
	});

	it('Make Proposal (New Account: 10, Old Account: 1): Valid', async () => {
		var newAccount = accounts[9];
		var oldAccount = accounts[0];

		await ProposalManagerInstance.MakeProposal(oldAccount, { from: newAccount });
		console.log(( await ProposalManagerInstance.getActiveVotingTokensSender(oldAccount, newAccount)));
	});

	it('Cast a Vote (Yes Votes)', async () => {
		var newAccount = accounts[9];
		var oldAccount = accounts[0];

		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await ProposalManagerInstance.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong");
	});	

	/*
	it('Cast a Vote (No Votes)', async () => {
		await VotingTokenInstance.CastVote(accounts[1], false);
		temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 1, "Wrong");
	});

	it('Cast a Vote (Duplicate Votes)', async () => {
		await VotingTokenInstance.CastVote(accounts[0], true);
		var temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 1, "Wrong");
	});

	it('Result (False)', async () => {
		await VotingTokenInstance.CountVotes(newAccount);
		var temp = (await VotingTokenInstance.getOutcome());
		assert.equal(temp, false, "Wrong");
	});

	it('Result (True)', async () => {
		await VotingTokenInstance.CastVote(accounts[2], true);
		var temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 2, "Wrong 0");

		await VotingTokenInstance.CountVotes(newAccount);

		temp = (await VotingTokenInstance.getResult()).toNumber();
		// console.log(temp);

		var temp2 = (await VotingTokenInstance.getOutcome());
		assert.equal(temp2, true, "Wrong 1");
	});	
	*/


});

