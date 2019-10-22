const TransactionManager = artifacts.require("TransactionManager");
var TransactionManagerInstance;

const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

function Transaction(sender, receiver, amount) {
	this.sender = sender;
	this.receiver = receiver;
	this.amount = amount;
}

contract('TransactionManager', (accounts) => {

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
		TransactionManagerInstance = await TransactionManager.deployed(UserManagerInstance.address);
	});

	it('Send Money (Account[1] to Account[2]): Valid', async () => {
		const sender = accounts[1];
		const receiver = accounts[2];

		const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await TransactionManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});

	it('View Transaction (Account[1] to Account[2]): Valid', async () => {
		var senderStart = accounts[1];
		var receiverStart = accounts[2];

		var temp = await TransactionManagerInstance.getTransactionJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});

	it('Buy Coins (accounts[4]): Valid', async () => {
		const buyer = accounts[4];

		const buyerStartingBalance = (await UserManagerInstance.getUserBalance(buyer)).toNumber();

		const amount = 1000000000000000000;				// 1 ETH -> 100 Coins
		await TransactionManagerInstance.BuyCoin({ from: buyer, value: amount});

		const buyerEndingBalance = (await UserManagerInstance.getUserBalance(buyer)).toNumber();

		assert.equal(buyerEndingBalance, buyerStartingBalance + (amount/10000000000000000), "Amount wasn't correctly given to the buyer");
	});
});
