const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const ProposalManager = artifacts.require("ProposalManager");
var PMI;

const ProposalCreator = artifacts.require("ProposalCreator");
var PCI;

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

	const newAccount = accounts[8];
	const oldAccount = accounts[0];

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
		TransactionManagerInstance = await TransactionManager.deployed(UserManagerInstance.address);
		PMI = await ProposalManager.deployed(UserManagerInstance.address, TransactionManagerInstance.address);
		PCI = await ProposalCreator.deployed(UserManagerInstance.address, TransactionManagerInstance.address, ProposalManager.address);
	});

	it('Buy Coins (accounts[0,8]): Valid', async () => {
		const amount = 10000000000000000000;				// 10 ETH -> 1000 Coins
		await TransactionManagerInstance.BuyCoin({ from: oldAccount, value: amount});
		const endingBalance = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();
		assert.equal(endingBalance, 1000, "Old Account did not buy the right amount of coins");

		const amount2 = 1000000000000000000;				// 1 ETH -> 100 Coins
		await TransactionManagerInstance.BuyCoin({ from: newAccount, value: amount2});
		const endingBalance2 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();
		assert.equal(endingBalance2, 100, "New Account did not buy the right amount of coins");

	});

	it('Send Money (Account[0] to Accounts[1,2,3,4,5,6,7]): Valid', async () => {
		const amount = 10;
		for (i = 1; i <= 7; i++) {
			const senderStartingBalance = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();
			await TransactionManagerInstance.MakeTransaction(accounts[i], amount, { from: oldAccount });
			const senderEndingBalance = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();
			assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		}
	});

	it('Start Proposal (New Account[8], Old Account[0]): Valid', async () => {
		await PCI.StartProposal(oldAccount, "HI: Proposal", { from: newAccount });
	});


	it('Pay for Proposal: Valid', async () => {
		const A1 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();

		await PCI.Pay(oldAccount, true, { from: newAccount });
		
		const A2 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();
		const B = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();

		// console.log("New Account Balance Before: " + A1);
		// console.log("New Account Balance After: " + A2);
		// console.log("Old Account Balance: " + B);
	});

	var TradePartners = [accounts[1], accounts[2], accounts[3], accounts[4]];

	it('Add Trading Partners: [1,2,3,4]: Valid', async () => {
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});

	it('Find Randomly assigned Voter: Valid', async () => {
		for (var i = 0; i < 3; i++) {
			await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
			var voter = (await PCI.ViewRandomTradingPartner(oldAccount, { from: newAccount }));
			await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
			// console.log("Random voter: " + voter);
			TradePartners.push(voter);
		}
	});

	it('Make Voting Token: Valid', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeVotingToken(oldAccount, TradePartners[i], "HI", { from: newAccount });
		}
	});

	const timeStamp = 1;
	const amount = 10;
	const receiver = accounts[1];
	const sender = oldAccount;
	const description = "AAA";
	const itemsInTrade = "BBB";

	it('Add Transaction Data Set: Valid', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeTransactionDataSet(oldAccount, timeStamp, amount, TradePartners[i], description, itemsInTrade, { from: newAccount });
		}
	});

	it('View Public Information: Valid', async () => {
		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, 0, {from: receiver}));
		var dataSet = new PublicInfo(temp[0], temp[1], temp[2], temp[3]);

		assert.equal(dataSet.timeStamp, timeStamp, "Wrong dataSet.timeStamp");
		assert.equal(dataSet.amount, amount, "Wrong dataSet.amount");
		assert.equal(dataSet.receiver, receiver, "Wrong dataSet.receiver");
		assert.equal(dataSet.sender, sender, "Wrong dataSet.sender");
	});

	it('View Private Information: Valid', async () => {
		var temp = (await PMI.ViewPrivateInformation(oldAccount, newAccount, 0, {from: receiver}));
		var dataSet = new PrivateInfo(temp[0], temp[1]);

		assert.equal(dataSet.description, description, "Wrong dataSet.description");
		assert.equal(dataSet.itemsInTrade, itemsInTrade, "Wrong dataSet.itemsInTrade");
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
		const before0 = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();
		const before1 = (await UserManagerInstance.getUserBalance(accounts[1])).toNumber();
		const before2 = (await UserManagerInstance.getUserBalance(accounts[2])).toNumber();
		const before3 = (await UserManagerInstance.getUserBalance(accounts[3])).toNumber();
		const before4 = (await UserManagerInstance.getUserBalance(accounts[4])).toNumber();
		const before8 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();

		await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount});
		var temp = (await PMI.getArchivedProposals(oldAccount, newAccount));
		assert.equal(temp[0], true, "Wrong Outcome");

		const after0 = (await UserManagerInstance.getUserBalance(oldAccount)).toNumber();
		const after1 = (await UserManagerInstance.getUserBalance(accounts[1])).toNumber();
		const after2 = (await UserManagerInstance.getUserBalance(accounts[2])).toNumber();
		const after3 = (await UserManagerInstance.getUserBalance(accounts[3])).toNumber();
		const after4 = (await UserManagerInstance.getUserBalance(accounts[4])).toNumber();
		const after8 = (await UserManagerInstance.getUserBalance(newAccount)).toNumber();

		assert.equal(after0, 0, "Did not take the money from the old account");
		assert.equal(after8, before8 + before0, "Did not give the money to the new account");
		assert.equal(after1, after2, "Did not award the same amount of money");
		assert.equal(after2, after3, "Did not award the same amount of money 2");
		assert.isAbove(after1, after4, "Voter was not rewarded for voting correctly");

		// console.log("Before[0]: " + before0 + ",  \tAfter[0]: " + after0);
		// console.log("Before[1]: " + before1 + ",  \tAfter[1]: " + after1);
		// console.log("Before[2]: " + before2 + ",  \tAfter[2]: " + after2);
		// console.log("Before[3]: " + before3 + ",  \tAfter[3]: " + after3);
		// console.log("Before[4]: " + before4 + ",  \tAfter[4]: " + after4);
		// console.log("Before[8]: " + before8 + ",  \tAfter[8]: " + after8);
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
