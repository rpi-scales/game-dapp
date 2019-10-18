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

	const newAccount = accounts[9];
	const oldAccount = accounts[0];

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

	it('Start Proposal (New Account[9], Old Account[0]): Valid', async () => {
		await PMI.StartProposal(oldAccount, "HI: Proposal", { from: newAccount });
	});

	it('Pay for Proposal (New Account[9], Old Account[0]): Valid', async () => {
		const A1 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();

		await PMI.Pay(oldAccount, true, { from: newAccount });
		
		const A2 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();
		const B = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();

		console.log("New Account Balance Before: " + A1);
		console.log("New Account Balance After: " + A2);
		console.log("Old Account Balance: " + B);
	});

	it('Add Trading Partners (New Account[9], Old Account[0], TradePartners: [1,2,3,4]): Valid', async () => {
		var TradePartners = [accounts[1], accounts[2], accounts[3], accounts[4]];
		await PMI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});

	it('Find Randomly assigned Voter (New Account[9], Old Account[0]): Valid', async () => {
		var voter = (await PMI.FindRandomTradingPartner(oldAccount, { from: newAccount }));
		await PMI.AddRandomTradingPartner(oldAccount, true, { from: newAccount });

		voter = (await PMI.FindRandomTradingPartner(oldAccount, { from: newAccount }));
		await PMI.AddRandomTradingPartner(oldAccount, true, { from: newAccount });

		voter = (await PMI.FindRandomTradingPartner(oldAccount, { from: newAccount }));
		await PMI.AddRandomTradingPartner(oldAccount, true, { from: newAccount });

		// console.log(voter);
	});

	it('Make Voting Token (New Account[9], Old Account[0], Voter[1,2,3,4]): Valid', async () => {
		await PMI.MakeVotingToken(oldAccount, accounts[1], "HI: 1", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[2], "HI: 2", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[3], "HI: 3", { from: newAccount });
		await PMI.MakeVotingToken(oldAccount, accounts[4], "HI: 4", { from: newAccount });
	});

	const timeStamp = 1;
	const amount = 10;
	const receiver = accounts[1];
	const sender = oldAccount;
	const description = "AAA";
	const itemsInTrade = "BBB";

	it('Add Transaction Data Set (New Account[9], Old Account[0], Voter[1,2,3,4]: Valid', async () => {
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, receiver, description, itemsInTrade, { from: newAccount });
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[2], description, itemsInTrade, { from: newAccount });
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[3], description, itemsInTrade, { from: newAccount });
		await PMI.MakeTransactionDataSet(oldAccount, timeStamp, amount, accounts[4], description, itemsInTrade, { from: newAccount });
	});

	/*
	it('View Public Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, 0, {from: receiver}));
		var dataSet = new PublicInfo(temp[0], temp[1], temp[2], temp[3]);

		assert.equal(dataSet.timeStamp, timeStamp, "Wrong dataSet.timeStamp");
		assert.equal(dataSet.amount, amount, "Wrong dataSet.amount");
		assert.equal(dataSet.receiver, receiver, "Wrong dataSet.receiver");
		assert.equal(dataSet.sender, sender, "Wrong dataSet.sender");
	});

	it('View Private Information (New Account[9], Old Account[0], Voter[1]: Valid', async () => {
		var temp2 = (await PMI.ViewPrivateInformation(oldAccount, newAccount, 0, {from: accounts[1]}));
		var dataSet2 = new PrivateInfo(temp2[0], temp2[1]);

		assert.equal(dataSet2.description, description, "Wrong dataSet.description");
		assert.equal(dataSet2.itemsInTrade, itemsInTrade, "Wrong dataSet.itemsInTrade");
	});

	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[1] });
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[2] });
		await PMI.CastVote(oldAccount, newAccount, true, { from: accounts[3] });
	});	

	it('Cast a Vote (No Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, false, { from: accounts[4] });
	});	

	it('Conclude Account Recovery', async () => {
		const before0 = (await UserManagerInstance.getUserBalance(accounts[0])).toNumber();
		const before1 = (await UserManagerInstance.getUserBalance(accounts[1])).toNumber();
		const before2 = (await UserManagerInstance.getUserBalance(accounts[2])).toNumber();
		const before3 = (await UserManagerInstance.getUserBalance(accounts[3])).toNumber();
		const before4 = (await UserManagerInstance.getUserBalance(accounts[4])).toNumber();
		const before9 = (await UserManagerInstance.getUserBalance(accounts[9])).toNumber();

		var outcome = (await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount}));
		//assert.equal(outcome, true, "Wrong Outcome");

		const after0 = (await UserManagerInstance.getUserBalance(accounts[0])).toNumber();
		const after1 = (await UserManagerInstance.getUserBalance(accounts[1])).toNumber();
		const after2 = (await UserManagerInstance.getUserBalance(accounts[2])).toNumber();
		const after3 = (await UserManagerInstance.getUserBalance(accounts[3])).toNumber();
		const after4 = (await UserManagerInstance.getUserBalance(accounts[4])).toNumber();
		const after9 = (await UserManagerInstance.getUserBalance(accounts[9])).toNumber();

		console.log("Before[0]: " + before0 + ",  \tAfter[0]: " + after0);
		console.log("Before[1]: " + before1 + ",  \tAfter[1]: " + after1);
		console.log("Before[2]: " + before2 + ",  \tAfter[2]: " + after2);
		console.log("Before[3]: " + before3 + ",  \tAfter[3]: " + after3);
		console.log("Before[4]: " + before4 + ",  \tAfter[4]: " + after4);
		console.log("Before[9]: " + before9 + ",  \tAfter[9]: " + after9);
	});
	*/

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
