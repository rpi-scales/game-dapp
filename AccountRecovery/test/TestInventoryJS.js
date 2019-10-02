const VotingToken = artifacts.require("VotingToken");
var oldAccount;
var newAccount;
var VotingTokenInstance;

contract('VotingToken', (accounts) => {

	it('Create Vote Token', async () => {
		oldAccount = accounts.shift();
		newAccount = accounts.shift();
		VotingTokenInstance = await VotingToken.deployed(accounts, oldAccount, newAccount);
	});	

	it('Cast a Vote (Yes Votes)', async () => {
		await VotingTokenInstance.CastVote(accounts[0], true);
		var temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 1, "Wrong");
	});	

	it('Cast a Vote (No Votes)', async () => {
		await VotingTokenInstance.CastVote(accounts[1], false);
		temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 1, "Wrong");
	});

	it('Cast a Vote (Duplicate Votes)', async () => {
		await VotingTokenInstance.CastVote(accounts[0], true);
		var temp = (await VotingTokenInstance.getVotes()).toNumber();
		assert.equal(temp, 1, "Wrong 0");
	});
});

