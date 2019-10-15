const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const ProposalManager = artifacts.require("ProposalManager");
var PMI;

function PublicInfo(timeStamp, amount, sender, receiver) {
	this.timeStamp = timeStamp;
	this.amount = amount;
	this.sender = sender;
	this.receiver = receiver;
}

function PrivateInfo(description, itemsInTrade) {
	this.description = description;
	this.itemsInTrade = itemsInTrade;
}

contract('ProposalManager', (accounts) => {

	var newAccount = accounts[9];
	var oldAccount = accounts[0];

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
		TransactionManagerInstance = await TransactionManager.deployed(UserManagerInstance.address);
		PMI = await ProposalManager.deployed(UserManagerInstance.address, TransactionManagerInstance.address);
	});

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

	it('Make Proposal (New Account[9], Old Account[0], TradePartners: [1,2,3,4]): Valid', async () => {
		var TradePartners = [accounts[1], accounts[2], accounts[3], accounts[4]];

		var temp = (await PMI.MakeProposal.estimateGas(oldAccount, TradePartners, "HI", { from: newAccount }));
		console.log("GAS: " + temp);
		await PMI.MakeProposal(oldAccount, TradePartners, "HI: Proposal", { from: newAccount });
	});

	it('Make Voting Token (New Account[9], Old Account[0], Voter[1,2,3,4]): Valid', async () => {
		await PMI.MakeVotingToken(oldAccount, accounts[1], "HI: 1", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[2], "HI: 2", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[3], "HI: 3", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[4], "HI: 4", { from: newAccount });
	});

	it('Add Transaction Data Set (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		const timeStamp = 1;
		const amount = 10;
		const receiver = accounts[1];
		const sender = oldAccount;
		const description = "1: AAA";
		const itemsInTrade = "1: BBB";

		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, receiver, description, itemsInTrade, { from: newAccount });

		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, 0, {from: receiver}));
		var dataSet = new PublicInfo(temp[0], temp[1], temp[2], temp[3]);

		var temp2 = (await PMI.ViewPrivateInformation(oldAccount, newAccount, 0, {from: accounts[1]}));
		var dataSet2 = new PrivateInfo(temp2[0], temp2[1]);

		assert.equal(dataSet.timeStamp, timeStamp, "Wrong dataSet.timeStamp");
		assert.equal(dataSet.amount, amount, "Wrong dataSet.amount");
		assert.equal(dataSet.receiver, receiver, "Wrong dataSet.receiver");
		assert.equal(dataSet.sender, sender, "Wrong dataSet.sender");

		assert.equal(dataSet2.description, description, "Wrong dataSet.description");
		assert.equal(dataSet2.itemsInTrade, itemsInTrade, "Wrong dataSet.itemsInTrade");

		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[2], description, itemsInTrade, { from: newAccount });
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[3], description, itemsInTrade, { from: newAccount });
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[4], description, itemsInTrade, { from: newAccount });
	});

	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	it('Cast a Vote (No Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, false, { from: accounts[2] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	it('Result (False)', async () => {
		await PMI.CountVotes(oldAccount, newAccount, {from: newAccount});
		var outcome = (await PMI.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, false, "Wrong Outcome");
	});

	it('Result (True)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[3] });
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[4] });

		await PMI.CountVotes(oldAccount, newAccount, {from: newAccount});

		var outcome = (await PMI.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, true, "Wrong Outcome");
	});

	it('Random', async () => {
		var temp = (await PMI.random(accounts[1], 255)).toNumber();
		console.log(temp);
	});












	/*
	it('Cast a Vote (Duplicate Votes): Invalid', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	it('Make Voting Token (New Account[9], Old Account[0], Voter[1]): Invalid', async () => {
		await PMI.MakeVotingToken(oldAccount, 2, 20, accounts[1], { from: newAccount });
	});

	*/
});
