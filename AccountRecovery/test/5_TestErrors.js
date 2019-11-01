const UserManager = artifacts.require("UserManager");
var UMI;		// UserManagerInstance

const TransactionManager = artifacts.require("TransactionManager");
var TMI;		// TransactionManagerInstance

const ProposalManager = artifacts.require("ProposalManager");
var PMI;		// ProposalManagerInstance

const ProposalCreator = artifacts.require("ProposalCreator");
var PCI;		// ProposalCreatorInstance

contract('UserManager: Invalid Tests', (accounts) => {

	var newAccount = accounts[8];
	var oldAccount = accounts[0];

	it('Valid: Constructor', async () => {
		UMI = await UserManager.deployed(accounts);
		TMI = await TransactionManager.deployed(UMI.address);
		PMI = await ProposalManager.deployed(UMI.address, TMI.address);
		PCI = await ProposalCreator.deployed(UMI.address, TMI.address, ProposalManager.address);
	});

	it('Getting a user that does not exist', async () => {
		const admin = (await UMI.getAdmin());
		console.log(await UMI.getUserBalance(admin));
	});

	it('Valid: Change Veto Time', async () => {
		await UMI.changeVetoTime(1, {from: oldAccount});
	});


	/*
	it('Sending money to the admin', async () => {
		const admin = (await UMI.getAdmin());
		await TMI.MakeTransaction(admin, 10, {from: accounts[1]});
	});
	*/
	/*
	it('Sending money to yourself', async () => {
		await TMI.MakeTransaction(accounts[0], 10, {from: accounts[0]});
	});
	*/
	/*
	it('Not having enough money for a transaction', async () => {
		await TMI.MakeTransaction(accounts[1], 10, {from: accounts[0]});
	});
	*/
	/*
	it('Getting a transaction that does not exist', async () => {
		await TMI.getTransactionJS(accounts[0], accounts[1], 10);
	});
	*/



	/*
	it('Creating a proposal to recover your own account', async () => {
		await PCI.StartProposal(accounts[0], "AA", {from: newAccount});
	});
	*/
	/*
	it('Trying to recover the admin', async () => {
		const admin = (await UMI.getAdmin());
		await PCI.StartProposal(admin, "AA", {from: newAccount});	
	});
	*/

	it('Valid: Buy Coins for old account', async () => {
		const amount = 10000000000000000000;				// 10 ETH -> 1000 Coins
		await TMI.BuyCoin({ from: oldAccount, value: amount});
		const endingBalance = (await UMI.getUserBalance(oldAccount)).toNumber();
		assert.equal(endingBalance, 1000, "Old Account did not buy the right amount of coins");
	});

	it('Valid: Send Money from old account to indicated trade partners: Valid', async () => {
		const amount = 10;
		for (i = 1; i <= 6; i++) {
			await TMI.MakeTransaction(accounts[i], amount, { from: oldAccount });
		}
	});

	it('Valid: Creating a valid proposal', async () => {
		await PCI.StartProposal(oldAccount, "AA", {from: newAccount});	
	});

	/*
	it('There already exists a proposal', async () => {
		await PCI.StartProposal(oldAccount, "AA", {from: newAccount});	
	});
	*/
	/*
	it('Pay without enough money', async () => {
		await PCI.Pay(oldAccount, true, { from: newAccount });
	});
	*/
	/*
	it('Adding trade partners before paying', async () => {
		var TradePartners = [accounts[1], accounts[2], accounts[3]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/

	it('Valid: Buy Coins for new account', async () => {
		const amount = 1000000000000000000;				// 1 ETH -> 100 Coins
		await TMI.BuyCoin({ from: newAccount, value: amount});
		const endingBalance = (await UMI.getUserBalance(newAccount)).toNumber();
		assert.equal(endingBalance, 100, "New Account did not buy the right amount of coins");
	});

	it('Valid: Pay for Proposal', async () => {
		await PCI.Pay(oldAccount, true, { from: newAccount });
	});

	/*
	it('Not enough indicated trade partners up front', async () => {
		var TradePartners = [accounts[1]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/
	/*
	it('Not have enough of the indicated trade partners be actual trade parttners', async () => {
		var TradePartners = [accounts[1], accounts[7], accounts[8]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/
	/*
	it('Do not have enough of the other trade partners', async () => {
		var TradePartners = [accounts[1], accounts[2], accounts[3], accounts[4], accounts[5]];
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});
	*/
	/*
	it('Finding randomly assigned voter before adding trading partners', async () => {
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
	});
	*/

	var TradePartners = [accounts[1], accounts[2], accounts[3]];
	it('Valid: Add Trading Partners: [1,2,3]', async () => {
		await PCI.AddTradePartners(oldAccount, TradePartners, { from: newAccount });
	});

	/*
	it('Vetoing a randomly assigned voter too many times', async () => {
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
	});
	*/

	/*
	it('Not having enough trade partners left after veto', async () => {
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
	});
	*/
	/*
	it('Adding the default randomly assigned voter', async () => {
		await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
	});
	*/
	/*
	it('Adding the same voter twice', async () => {
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
	});
	*/
	/*
	it('Making a voting token before finding all the voters', async () => {
		await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
		await PCI.MakeVotingToken(oldAccount, TradePartners[0], "HI", { from: newAccount });
	});
	*/

	it('Valid: Adding randomly assigned voters', async () => {
		for (var i = 0; i < 3; i++) {
			await PCI.FindRandomTradingPartner(oldAccount, { from: newAccount });
			var voter = (await PCI.ViewRandomTradingPartner(oldAccount, { from: newAccount }));
			await PCI.AddRandomTradingPartner(oldAccount, { from: newAccount });
			console.log("Random voter: " + voter);
			TradePartners.push(voter);
		}
	});

	/*
	it('Cast a Vote (Yes Votes)', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: TradePartners[0] });
	});
	*/	

	/*
	it('Concluding the vote before creating all voting tokens', async () => {
		await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount});
	});
	*/

	it('Valid: Make Voting Token', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeVotingToken(oldAccount, TradePartners[i], "HI", { from: newAccount });
		}
	});

	/*
	it('Casting a before transaction data was added vote', async () => {
		await PMI.CastVote(oldAccount, newAccount, true, { from: TradePartners[0] });
	});
	*/
	/*
	it('Adding wrong Transaction Data Set', async () => {
		await PCI.MakeTransactionDataSet(oldAccount, 1, 55, TradePartners[0], "AAA", "BBB", { from: newAccount });
	});
	*/
	/*
	it('Concluding the vote before adding all transaction data', async () => {
		await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount});
	});
	*/

	it('Valid: Add Transaction Data Set', async () => {
		for (var i = 0; i < TradePartners.length; i++) {
			await PCI.MakeTransactionDataSet(oldAccount, 1, 10, TradePartners[i], "AAA", "BBB", { from: newAccount });
		}
	});

	/*
	it('Concluding the vote before enough voters have voted', async () => {
		await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount});
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
	it('Valid: Concluding a failed vote', async () => {
		const before0 = (await UMI.getUserBalance(oldAccount)).toNumber();
		const before1 = (await UMI.getUserBalance(accounts[1])).toNumber();
		const before2 = (await UMI.getUserBalance(accounts[2])).toNumber();
		const before3 = (await UMI.getUserBalance(accounts[3])).toNumber();
		const before4 = (await UMI.getUserBalance(accounts[4])).toNumber();
		const before5 = (await UMI.getUserBalance(accounts[5])).toNumber();
		const before6 = (await UMI.getUserBalance(accounts[6])).toNumber();
		const before8 = (await UMI.getUserBalance(newAccount)).toNumber();

		await PMI.ConcludeAccountRecovery(oldAccount, {from: newAccount});
		// var temp = (await PMI.getArchivedProposals(oldAccount, newAccount));
		// assert.equal(temp[0], true, "Wrong Outcome");

		const after0 = (await UMI.getUserBalance(oldAccount)).toNumber();
		const after1 = (await UMI.getUserBalance(accounts[1])).toNumber();
		const after2 = (await UMI.getUserBalance(accounts[2])).toNumber();
		const after3 = (await UMI.getUserBalance(accounts[3])).toNumber();
		const after4 = (await UMI.getUserBalance(accounts[4])).toNumber();
		const after5 = (await UMI.getUserBalance(accounts[5])).toNumber();
		const after6 = (await UMI.getUserBalance(accounts[6])).toNumber();
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
		assert.isAbove(after1, before1, "Voter 1 was not rewarded for voting correctly");
		assert.isAbove(after2, before2, "Voter 2 was not rewarded for voting correctly");
		assert.isAbove(after3, before3, "Voter 3 was not rewarded for voting correctly");
		assert.isAbove(after4, before4, "Voter 4 was not rewarded for voting correctly");
		assert.isAbove(after5, before5, "Voter 5  was not rewarded for voting correctly");
		assert.isAbove(after6, before6, "Voter 6 was not rewarded for voting correctly");
	});

	/*
	it('Creating a proposal after a failed vote', async () => {
		await PCI.StartProposal(oldAccount, "AA", {from: newAccount});	
	});
	*/

});
