const Coin = artifacts.require("Coin");

contract('Coin', (accounts) => {
	it('should put 10000 Coin in the first account', async () => {
		const coinInstance = await Coin.deployed();
		const balance = (await coinInstance.getBalance.call(accounts[0])).toNumber();
		
		assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
	});

	
	it('should send coin correctly', async () => {
		const coinInstance = await Coin.deployed();

		// Setup 2 accounts.
		const accountOne = accounts[0];
		const accountTwo = accounts[1];

		// Get initial balances of first and second account.
		const accountOneStartingBalance = (await coinInstance.getBalance.call(accountOne)).toNumber();
		const accountTwoStartingBalance = (await coinInstance.getBalance.call(accountTwo)).toNumber();

		// Make transaction from first account to second.
		const amount = 10;
		await coinInstance.sendCoin(accountTwo, amount, { from: accountOne });

		// Get balances of first and second account after the transactions.
		const accountOneEndingBalance = (await coinInstance.getBalance.call(accountOne)).toNumber();
		const accountTwoEndingBalance = (await coinInstance.getBalance.call(accountTwo)).toNumber();


		assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});
	
});

