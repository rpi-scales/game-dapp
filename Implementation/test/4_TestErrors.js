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

var newAccount;
var oldAccount;

contract('Invalid Tests', (accounts) => {
	var users = accounts.slice();
	users.shift();

	newAccount = users[8];
	oldAccount = users[0];

	it('Valid: Constructor', async () => {
		UMI = await UserManager.deployed(users);
		TMI = await TransactionManager.deployed(UMI.address);
		PMI = await ProposalManager.deployed(UMI.address, TMI.address);
		PCI = await ProposalCreator.deployed(UMI.address, TMI.address, ProposalManager.address);
	});
	/*
	it('Getting a user that does not exist', async () => {
		const admin = (await UMI.getAdmin());
		console.log(await UMI.getUserBalance(admin));
	});
	*/
	it('Valid: Change Veto Time', async () => {
		await UMI.changeVetoTime(1, {from: oldAccount});
	});
	/*
	it('Sending money to the admin', async () => {
		const admin = (await UMI.getAdmin());
		await TMI.MakeTransaction(admin, 10, {from: users[1]});
	});
	*/
	/*
	it('Sending money to yourself', async () => {
		await TMI.MakeTransaction(users[0], 10, {from: users[0]});
	});
	*/
	/*
	it('Not having enough money for a transaction', async () => {
		await TMI.MakeTransaction(users[1], 10, {from: users[0]});
	});
	*/
	/*
	it('Getting a transaction that does not exist', async () => {
		await TMI.getTransactionJS(users[0], users[1], 10);
	});
	*/
	/*
	it('Look up a Proposal that does not exist', async () => {
		await PCI.Pay(oldAccount, true, { from: newAccount });
	});
	*/
	/*
	it('Creating a proposal to recover your own account', async () => {
		await PCI.StartProposal(users[0], {from: newAccount});
	});
	*/
	/*
	it('Trying to recover the admin', async () => {
		const admin = (await UMI.getAdmin());
		await PCI.StartProposal(admin, {from: newAccount});	
	});
	*/
	it('Valid: Buy Coins for old account', async () => {
		await TMI.BuyCoin({ from: oldAccount, value: 10000000000000000000});
	});

	var timeStamps = [];

	it('Valid: Send Money from old account to indicated trade partners: Valid', async () => {
		const amount = 10;
		for (i = 1; i <= 8; i++) {
			var date = new Date();
			await TMI.MakeTransaction(users[i], amount, { from: oldAccount });
			timeStamps.push(parseInt(date.getTime()/1000));
		}
	});

	it('Valid: Creating a valid proposal', async () => {
		await PCI.StartProposal(oldAccount, {from: newAccount});	
	});

	/*
	it('There already exists a proposal', async () => {
		await PCI.StartProposal(oldAccount, {from: newAccount});	
	});
	*/
	/*
	it('Pay without enough money', async () => {
		await PCI.Pay(oldAccount, true, { from: newAccount });
	});
	*/
	/*
	it('Adding trade partners before paying', async () => {
		var TradePartners = [users[1], users[2], users[3]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/

	it('Valid: Buy Coins for new account', async () => {
		await TMI.BuyCoin({ from: newAccount, value: 1000000000000000000});
	});

	it('Valid: Pay for Proposal', async () => {
		await PCI.Pay(oldAccount, true, { from: newAccount });
	});

	/*
	it('Do not have enough of the other trade partners', async () => {
		var TradePartners = [users[1], users[2], users[3], users[4], users[5]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/
	/*
	it('Finding randomly assigned voter before adding trading partners', async () => {
		await PCI.RandomTradingPartner(oldAccount, false, { from: newAccount });

	});
	*/

	var TradePartners = [users[1], users[2]];
	it('Valid: Add Trading Partners: [1,2,3]', async () => {
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});

	/*
	it('Not having enough trade partners left after veto', async () => {
		await PCI.RandomTradingPartner(oldAccount, true, { from: newAccount });
		await PCI.RandomTradingPartner(oldAccount, true, { from: newAccount });
		await PCI.RandomTradingPartner(oldAccount, true, { from: newAccount });
	});
	*/

	it('Valid: Adding randomly assigned voters', async () => {
		for (var i = 0; i < 3; i++) {
			var voter = (await PCI.ViewRandomTradingPartner(oldAccount, { from: newAccount }));
			await PCI.RandomTradingPartner(oldAccount, false, { from: newAccount });
			console.log("Random voter: " + voter);
			TradePartners.push(voter);
		}
	});

	/*
	it('Adding the same voter twice', async () => {
		await PCI.RandomTradingPartner(oldAccount, false, { from: newAccount });
	});
	*/
	/*
	it('Casting a vote before transaction data was added', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: TradePartners[0] });
	});
	*/
	/*
	it('Adding wrong Transaction Data Set', async () => {
		await PCI.MakeTransactionDataSet(oldAccount, 1, 55, TradePartners[0], "AAA", "BBB", "CCC", { from: newAccount });
	});
	*/
	/*
	it('Add transaction data for a voter that is not a voter', async () => {
		await PCI.MakeTransactionDataSet(oldAccount, 1, 10, users[8], "AAA", "BBB", "CCC", { from: newAccount });
	});
	*/
	/*
	it('Concluding the vote before adding all transaction data', async () => {
		await PMI.ConcludeProposal(oldAccount, {from: newAccount});
	});
	*/

	it('Valid: Adding transaction data', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeTransactionDataSet(oldAccount, TradePartners[i], timeStamps[i], 10,
				"AAA", "AAA", "AAA", "AAA",{ from: newAccount });
		}
	});

	/*
	it('Invalid user casting a vote', async () => {
		await PMI.CastVote(oldAccount, newAccount, false, { from: users[8] });
	});	
	*/
	/*
	it('Concluding the vote before enough voters have voted', async () => {
		await PMI.ConcludeProposal(oldAccount, {from: newAccount});
	});
	*/
	it('Valid: Cast votes', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PMI.CastVote(oldAccount, newAccount, false, { from: TradePartners[i] });
		}
	});

	/*
	it('Cast a Duplicate Vote', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: TradePartners[0] });
	});	
	*/
	/*
	it('Checking for bribery', async () => {
		await TMI.MakeTransaction(TradePartners[0], 1, { from: newAccount });
	});
	*/
	/*
	it('Checking for transacion from old account', async () => {
		await TMI.MakeTransaction(TradePartners[0], 1, { from: oldAccount });
	});
	*/
	/*
	it('Concluding the vote before veto time has elapsed', async () => {
		await PMI.ConcludeProposal(oldAccount, {from: newAccount});
	});
	*/

	it('Valid: Concluding a failed vote', async () => {
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

		console.log("Before[0]: " + before0 + ",  \tAfter[0]: " + after0);
		console.log("Before[1]: " + before1 + ",  \tAfter[1]: " + after1);
		console.log("Before[2]: " + before2 + ",  \tAfter[2]: " + after2);
		console.log("Before[3]: " + before3 + ",  \tAfter[3]: " + after3);
		console.log("Before[4]: " + before4 + ",  \tAfter[4]: " + after4);
		console.log("Before[5]: " + before5 + ",  \tAfter[5]: " + after5);
		console.log("Before[6]: " + before6 + ",  \tAfter[6]: " + after6);
		console.log("Before[8]: " + before8 + ",  \tAfter[8]: " + after8);

		assert.equal(after0, before0, "Did take the money from the old account");
		assert.equal(after8, before8, "Did give the money to the new account");
	});

	/*
	it('Creating a proposal after a failed vote', async () => {
		await PCI.StartProposal(oldAccount, {from: newAccount});	
	});
	*/

});
