const UserManager = artifacts.require("UserManager");
var UMI;		// UserManagerInstance

const TransactionManager = artifacts.require("TransactionManager");
var TMI;		// TransactionManagerInstance

const ProposalManager = artifacts.require("ProposalManager");
var PMI;		// ProposalManagerInstance

const ProposalCreator = artifacts.require("ProposalCreator");
var PCI;		// ProposalCreatorInstance

function sleep(ms) {
	return new Promise(resolve => setTimeout(resolve, ms));
}

contract('ProposalManager', (accounts) => {
	var users = accounts.slice();
	users.shift();

	const newAccount = users[8];
	const oldAccount = users[0];

	it('Constructor', async () => {
		UMI = await UserManager.deployed(users);
		TMI = await TransactionManager.deployed(UMI.address);
		PMI = await ProposalManager.deployed(UMI.address, TMI.address);
		PCI = await ProposalCreator.deployed(UMI.address, TMI.address, ProposalManager.address);
	});

	it('Change Veto Time', async () => {
		await UMI.changeVetoTime(1, {from: oldAccount});
	});

	it('Buy Coins (users[0,8])', async () => {
		const amount = 10000000000000000000;				// 10 ETH -> 1000 Coins
		await TMI.BuyCoin({ from: oldAccount, value: amount});
		const endingBalance = (await UMI.getUserBalance(oldAccount)).toNumber();
		assert.equal(endingBalance, 1000, "Old Account did not buy the right amount of coins");

		const amount2 = 1000000000000000000;				// 1 ETH -> 100 Coins
		await TMI.BuyCoin({ from: newAccount, value: amount2});
		const endingBalance2 = (await UMI.getUserBalance(newAccount)).toNumber();
		assert.equal(endingBalance2, 100, "New Account did not buy the right amount of coins");

	});

	var timeStamps = [];
	
	
	it('Send Money (Account[0] to users[1,2,3,4,5,6])', async () => {
		const amount = 10;
		for (i = 1; i <= 6; i++) {
			const senderStartingBalance = (await UMI.getUserBalance(oldAccount)).toNumber();


			var date = new Date();
			await TMI.MakeTransaction(users[i], amount, { from: oldAccount });
			timeStamps.push(parseInt(date.getTime()/1000));

			const senderEndingBalance = (await UMI.getUserBalance(oldAccount)).toNumber();
			assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		}
	});

	it('Start Proposal (New Account[8], Old Account[0])', async () => {
		await PCI.StartProposal(oldAccount, { from: newAccount });
	});

	it('Pay for Proposal', async () => {
		const A1 = (await UMI.getUserBalance(newAccount)).toNumber();

		const price = (	await PCI.ViewPrice(oldAccount, { from: newAccount }));
		await PCI.Pay(oldAccount, true, { from: newAccount });
		
		const A2 = (await UMI.getUserBalance(newAccount)).toNumber();
		const B = (await UMI.getUserBalance(oldAccount)).toNumber();

		// console.log("New Account Balance Before: " + A1);
		// console.log("New Account Balance After: " + A2);
		// console.log("Old Account Balance: " + B);
	});

	var TradePartners = [users[1], users[2], users[3]];

	it('Add Trading Partners: [1,2,3]', async () => {
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});

	it('Find Randomly assigned Voter', async () => {
		for (var i = 0; i < 3; i++) {
			var voter = (await PCI.ViewRandomTradingPartner(oldAccount, { from: newAccount }));
			await PCI.RandomTradingPartner(oldAccount, false, { from: newAccount });

			console.log("Random voter: " + voter);
			TradePartners.push(voter);
		}

		// console.log("Voters: " + (await PCI.ViewVoters(oldAccount, { from: newAccount })));

	});

	const amount = 10;
	const receiver = users[1];
	const sender = oldAccount;
	const description = "AAA";
	const itemsInTrade = "BBB";

	it('Add Transaction Data Set', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeTransactionDataSet(oldAccount, timeStamps[i], amount, TradePartners[i], description, itemsInTrade, { from: newAccount });
		}
	});

	it('View Public Information', async () => {
		var temp = (await PMI.ViewPublicInformation(oldAccount, newAccount, 0, {from: receiver}));

		// assert.equal(temp[0], timeStamp, "Wrong dataSet.timeStamp");
		assert.equal(temp[1], amount, "Wrong dataSet.amount");
		assert.equal(temp[2], sender, "Wrong dataSet.sender");
		assert.equal(temp[3], receiver, "Wrong dataSet.receiver");
	});

	it('View Private Information', async () => {
		var temp = (await PMI.ViewPrivateInformation(oldAccount, newAccount, 0, {from: receiver}));

		assert.equal(temp[0], description, "Wrong dataSet.description");
		assert.equal(temp[1], itemsInTrade, "Wrong dataSet.itemsInTrade");
	});

	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: users[1] });
		await sleep(1000);
		await PMI.CastVote(oldAccount, newAccount, true, { from: users[2] });
		await sleep(3000);
		await PMI.CastVote(oldAccount, newAccount, true, { from: users[3] });
		await sleep(1000);
		await PMI.CastVote(oldAccount, newAccount, true, { from: users[4] });
		await sleep(7000);
		await PMI.CastVote(oldAccount, newAccount, true, { from: users[5] });
	});	

	it('Cast a Vote (No Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, false, { from: users[6] });
	});	

	it('Conclude Proposal', async () => {
		const before0 = (await UMI.getUserBalance(oldAccount)).toNumber();
		const before1 = (await UMI.getUserBalance(users[1])).toNumber();
		const before2 = (await UMI.getUserBalance(users[2])).toNumber();
		const before3 = (await UMI.getUserBalance(users[3])).toNumber();
		const before4 = (await UMI.getUserBalance(users[4])).toNumber();
		const before5 = (await UMI.getUserBalance(users[5])).toNumber();
		const before6 = (await UMI.getUserBalance(users[6])).toNumber();
		const before8 = (await UMI.getUserBalance(newAccount)).toNumber();

		await PMI.ConcludeProposal(oldAccount, {from: newAccount});
		// var temp = (await PMI.getArchivedProposals(oldAccount, newAccount));
		// assert.equal(temp[0], true, "Wrong Outcome");

		const after0 = (await UMI.getUserBalance(oldAccount)).toNumber();
		const after1 = (await UMI.getUserBalance(users[1])).toNumber();
		const after2 = (await UMI.getUserBalance(users[2])).toNumber();
		const after3 = (await UMI.getUserBalance(users[3])).toNumber();
		const after4 = (await UMI.getUserBalance(users[4])).toNumber();
		const after5 = (await UMI.getUserBalance(users[5])).toNumber();
		const after6 = (await UMI.getUserBalance(users[6])).toNumber();
		const after8 = (await UMI.getUserBalance(newAccount)).toNumber();

		assert.equal(after0, 0, "Did not take the money from the old account");
		assert.equal(after8, before8 + before0, "Did not give the money to the new account");
		// assert.equal(after1, after2, "Did not award the same amount of money");
		// assert.equal(after2, after3, "Did not award the same amount of money 2");
		// assert.isAbove(after1, before1, "Voter was not rewarded for voting correctly");

		console.log("Before[0]: " + before0 + ",  \tAfter[0]: " + after0);
		console.log("Before[1]: " + before1 + ",  \tAfter[1]: " + after1);
		console.log("Before[2]: " + before2 + ",  \tAfter[2]: " + after2);
		console.log("Before[3]: " + before3 + ",  \tAfter[3]: " + after3);
		console.log("Before[4]: " + before4 + ",  \tAfter[4]: " + after4);
		console.log("Before[5]: " + before5 + ",  \tAfter[5]: " + after5);
		console.log("Before[6]: " + before6 + ",  \tAfter[6]: " + after6);
		console.log("Before[8]: " + before8 + ",  \tAfter[8]: " + after8);
	});
});
