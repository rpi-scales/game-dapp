const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const ProposalManager = artifacts.require("ProposalManager");
var PMI;

function PublicInfo(timeStamp, amount, receiver, sender) {
	this.timeStamp = timeStamp;
	this.amount = amount;
	this.receiver = receiver;
	this.sender = sender;
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
		console.log(temp);
		await PMI.MakeProposal(oldAccount, TradePartners, { from: newAccount });

	});

	/*
	it('Add Public Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		await PMI.AddPublicInformation(oldAccount, 1, 2, accounts[1], { from: newAccount });
	});

	it('View Public Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, {from: accounts[1]}));
		var dataSet = new PublicInfo(temp[0], temp[1], temp[2], temp[3]);

		console.log("timeStamp: " + dataSet.timeStamp);
		console.log("amount: " + dataSet.amount);
		console.log("receiver: " + dataSet.receiver);
		console.log("sender: " + dataSet.sender);
	});
	*/
	it('Add Private Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		await PMI.AddPrivateInformation(oldAccount, "5description", "6itemsInTrade", accounts[1], { from: newAccount });
	});

	it('View Private Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		var temp = (await PMI.ViewPrivateInformation(oldAccount, newAccount, {from: accounts[1]}));
		// console.log("temp: " + temp);

		var dataSet = new PrivateInfo(temp[0], temp[1]);

		console.log("description: " + dataSet.description);
		console.log("itemsInTrade: " + dataSet.itemsInTrade);
	});
	

	/*
	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	
	*/

	/*
	it('Cast a Vote (No Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, false, { from: accounts[2] });
		var temp = (await PMI.GetVotes(oldAccount, newAccount)).toNumber();
		assert.equal(temp, 1, "Wrong Number of Votes");
	});	


	it('Cast a Vote (Duplicate Votes): Invalid', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
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

		// var temp = (await PMI.getResult(oldAccount, newAccount)).toNumber();
		// console.log(temp);

		var outcome = (await PMI.getOutcome(oldAccount, newAccount));
		assert.equal(outcome, true, "Wrong Outcome");
	});
	*/
});
