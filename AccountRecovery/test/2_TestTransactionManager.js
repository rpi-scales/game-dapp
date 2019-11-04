const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

contract('TransactionManager', (accounts) => {
	var users = accounts.slice();
	users.shift();

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(users);
		TransactionManagerInstance = await TransactionManager.deployed(UserManagerInstance.address);
	});

	it('Buy Coins (users[0]): Valid', async () => {
		const buyer = users[0];
		const buyerStartingBalance = (await UserManagerInstance.getUserBalance(buyer)).toNumber();

		const amount = 1000000000000000000;				// 1 ETH -> 100 Coins
		await TransactionManagerInstance.BuyCoin({ from: buyer, value: amount});

		const buyerEndingBalance = (await UserManagerInstance.getUserBalance(buyer)).toNumber();
		assert.equal(buyerEndingBalance, buyerStartingBalance + (amount/10000000000000000), "Amount wasn't correctly given to the buyer");
	});

	it('Send Money (users[0] to users[1] ): Valid', async () => {
		const sender = users[0];
		const receiver = users[1];

		const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await TransactionManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});

	it('View Transaction (users[0] to users[1]): Valid', async () => {
		var senderStart = users[0];
		var receiverStart = users[1];

		var temp = await TransactionManagerInstance.getTransactionJS(senderStart, receiverStart, 0);

		assert.equal(temp[0], senderStart, "Wrong sender");
		assert.equal(temp[1], receiverStart, "Wrong receiver");
		assert.equal(temp[2], 10, "Wrong amount");
	});
});
