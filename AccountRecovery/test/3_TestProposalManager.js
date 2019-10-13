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
	
	/*
	it('Make Proposal (New Account: 10, Old Account: 1): Invalid', async () => {
		var newAccount = accounts[9];
		var oldAccount = accounts[0];

		await PMI.MakeProposal(oldAccount, { from: newAccount });
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

	it('Make Proposal (New Account[9], Old Account[0], TradePartners: [1,2,3,4]): Valid', async () => {
		var TradePartners = [accounts[1], accounts[2], accounts[3], accounts[4]];
		var temp = (await PMI.MakeProposal.estimateGas(oldAccount, TradePartners, { from: newAccount }));
		console.log("GAS: " + temp);
		await PMI.MakeProposal(oldAccount, TradePartners, { from: newAccount });
	});

	it('Make Voting Token (New Account[9], Old Account[0], Voter[1,2,3,4]): Valid', async () => {
		const timeStamp = 1;
		const amount = 2;
		const receiver = accounts[1];
		const sender = oldAccount;

		await PMI.MakeVotingToken(sender, timeStamp, amount, receiver, { from: newAccount });
		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, {from: receiver}));
		var dataSet = new PublicInfo(temp[0], temp[1], temp[2], temp[3]);

		assert.equal(dataSet.timeStamp, timeStamp, "Wrong dataSet.timeStamp");
		assert.equal(dataSet.amount, amount, "Wrong dataSet.amount");
		assert.equal(dataSet.receiver, receiver, "Wrong dataSet.receiver");
		assert.equal(dataSet.sender, sender, "Wrong dataSet.sender");


		await PMI.MakeVotingToken(sender, timeStamp, amount, accounts[2], { from: newAccount });
		await PMI.MakeVotingToken(sender, timeStamp, amount, accounts[3], { from: newAccount });
		await PMI.MakeVotingToken(sender, timeStamp, amount, accounts[4], { from: newAccount });
	});

	it('Add Private Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		const description = "AAA";
		const itemsInTrade = "BBB";

		await PMI.AddPrivateInformation(oldAccount, description, itemsInTrade, accounts[1], { from: newAccount });
		var temp = (await PMI.ViewPrivateInformation(oldAccount, newAccount, {from: accounts[1]}));
		var dataSet = new PrivateInfo(temp[0], temp[1]);
		assert.equal(dataSet.description, description, "Wrong dataSet.description");
		assert.equal(dataSet.itemsInTrade, itemsInTrade, "Wrong dataSet.itemsInTrade");
	});
	
	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	

	it('Cast a Vote (No Votes)', async () => {
		await PMI.AddPrivateInformation(oldAccount, "description", "itemsInTrade", accounts[2], { from: newAccount });

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
		await PMI.AddPrivateInformation(oldAccount, "description", "itemsInTrade", accounts[3], { from: newAccount });
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[3] });

		await PMI.AddPrivateInformation(oldAccount, "description", "itemsInTrade", accounts[4], { from: newAccount });
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[4] });

		await PMI.CountVotes(oldAccount, newAccount, {from: newAccount});

		// var temp = (await PMI.getResult(oldAccount, newAccount)).toNumber();
		// console.log(temp);

		var outcome = (await PMI.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, true, "Wrong Outcome");
	});

	/*
	it('Cast a Vote (Duplicate Votes): Invalid', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	
	*/
});
