const Inventory = artifacts.require("Inventory");

contract('Inventory', (accounts) => {
	
	it('Increase Coin', async () => {
		const inventoryInstance = await Inventory.deployed();

		const accountOne = accounts[0];

		const startingCoinBalance = (await inventoryInstance.getCoinBalance.call(accountOne)).toNumber();

		const amount = 10;
		await inventoryInstance.incrementBalance(accountOne, amount);

		const endingCoinBalance = (await inventoryInstance.getCoinBalance.call(accountOne)).toNumber();

		assert.equal(endingCoinBalance, startingCoinBalance + amount, "Amount wasn't correctly given");

	});	


	it('should buy a GameObject', async () => {

		const inventoryInstance = await Inventory.deployed();

		// Setup 2 accounts.
		const accountOne = accounts[0];

		// Get initial balances of first and second account.
		const startingCoinBalance = (await inventoryInstance.getCoinBalance.call(accountOne)).toNumber();

		// Make transaction from first account to second.
		const amount = 10;
		await inventoryInstance.buy(amount, { from: accountOne });


		// Get balances of first and second account after the transactions.
		const endingGameObjectBalance = (await inventoryInstance.getGameObjectBalance.call(accountOne)).toNumber();
		console.log("endingGameObjectBalance: " + endingGameObjectBalance);

		const endingCoinBalance = (await inventoryInstance.getCoinBalance.call(accountOne)).toNumber();

		assert.equal(endingCoinBalance, startingCoinBalance - amount, "Amount wasn't correctly taken from the buyer");

		assert.equal(endingGameObjectBalance, 1, "Buyer does not have a GameObject");

	});	
});

