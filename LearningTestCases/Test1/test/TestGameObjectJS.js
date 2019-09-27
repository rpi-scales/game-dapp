const GameObject = artifacts.require("GameObject");

contract('GameObject', (accounts) => {
	it('should put 0 GameObject in the first account', async () => {
		const gameObjectInstance = await GameObject.deployed();
		const balance = (await gameObjectInstance.getBalance.call(accounts[0])).toNumber();
		
		assert.equal(balance.valueOf(), 0, "0 wasn't in the first account");
	});

	it('should buy a GameObject', async () => {
		const gameObjectInstance = await GameObject.deployed();

		// Setup 2 accounts.
		const accountOne = accounts[0];

		// Get initial balances of first and second account.
		const accountOneStartingBalance = (await gameObjectInstance.getBalance.call(accountOne)).toNumber();

		// Make transaction from first account to second.
		const amount = 10;
		await gameObjectInstance.buy(amount, { from: accountOne });

		// Get balances of first and second account after the transactions.
		const accountOneEndingBalance = (await gameObjectInstance.getBalance.call(accountOne)).toNumber();


		assert.equal(accountOneEndingBalance, accountOneStartingBalance + 1, "Did not buy a GameObject");
	});

});

