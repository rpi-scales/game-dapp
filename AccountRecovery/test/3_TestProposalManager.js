const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const ProposalManager = artifacts.require("ProposalManager");
var ProposalManagerInstance;

contract('ProposalManager', (accounts) => {

	var newAccount = accounts[9];
	var oldAccount = accounts[0];

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

	it('Send Money (Account[0] to Accounts[1,2,3,4,5,6,7,8]): Valid', async () => {
		const sender = accounts[0];

		const amount = 10;
		for (i = 1; i <= 8; i++) {
			const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			await TransactionManagerInstance.MakeTransaction(accounts[i], amount, { from: sender });
			const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		}
	});

	it('Make Proposal (New Account[9], Old Account[0], No TradePartners specified): Valid', async () => {
		await ProposalManagerInstance.MakeProposal(oldAccount, { from: newAccount });

		console.log("oldAccount: " + oldAccount);
		console.log("newAccount: " + newAccount);
		for (i = 0; i < 7; i++) {
			var voters = (await ProposalManagerInstance.GetVoters(oldAccount, newAccount, i));

			console.log(i + ": " + voters);
		}
		
	});
	
	it('Cast a Vote (Yes Votes)', async () => {
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[3] });
		var temp = (await ProposalManagerInstance.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	it('Cast a Vote (No Votes)', async () => {
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, false, { from: accounts[4] });
		var temp = (await ProposalManagerInstance.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	/*
	it('Cast a Vote (Duplicate Votes): Invalid', async () => {
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[3] });
		var temp = (await ProposalManagerInstance.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	
	*/

	it('Result (False)', async () => {
		await ProposalManagerInstance.CountVotes(oldAccount, newAccount, {from: newAccount});
		var outcome = (await ProposalManagerInstance.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, false, "Wrong Outcome");
	});

	it('Result (True)', async () => {
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[5] });
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[6] });
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[7] });
		await ProposalManagerInstance.CastVote(oldAccount, newAccount, true, { from: accounts[8] });

		await ProposalManagerInstance.CountVotes(oldAccount, newAccount, {from: newAccount});

		// var temp = (await ProposalManagerInstance.getResult(oldAccount, newAccount)).toNumber();
		// console.log(temp);

		var outcome = (await ProposalManagerInstance.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, true, "Wrong Outcome");
	});

	var new2Account = accounts[9];
	var old2Account = accounts[1];
	
	it('Send Money (Account[1] to Accounts[2,3,4,5,6,7,8]): Valid', async () => {
		const sender = accounts[1];

		const amount = 10;
		for (i = 2; i <= 8; i++) {
			const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			await TransactionManagerInstance.MakeTransaction(accounts[i], amount, { from: sender });
			const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
			assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		}
	});

	it('Make Proposal (New Account: [9], Old Account: [1], TradePartners: [2,3,4] ): Valid', async () => {
		var TradePartners = [accounts[2], accounts[3], accounts[4]];
		await ProposalManagerInstance.MakeProposalTradePartners(old2Account, TradePartners, { from: new2Account });

		console.log("old2Account: " + old2Account);
		console.log("new2Account: " + new2Account);
		for (i = 0; i < 7; i++) {
			var voters = (await ProposalManagerInstance.GetVoters(old2Account, new2Account, i));

			console.log(i + ": " + voters);
		}

	});
});
