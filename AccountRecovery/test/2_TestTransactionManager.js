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

	it('Send Money (Account[0] to Account[1]): Valid', async () => {
		const sender = accounts[0];
		const receiver = accounts[1];

		const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await TransactionManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});	

	it('View Transaction (Account[0] to Account[1]): Valid', async () => {
		var senderStart = accounts[0];
		var receiverStart = accounts[1];

		var temp = await TransactionManagerInstance.getTransactionJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});

	it('Send Money (Account[2] to Account[3]): Valid', async () => {
		const sender = accounts[2];
		const receiver = accounts[3];

		const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await TransactionManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});

	it('View Transaction (Account[2] to Account[3]): Valid', async () => {
		var senderStart = accounts[2];
		var receiverStart = accounts[3];

		var temp = await TransactionManagerInstance.getTransactionJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});

	/*
	it('Send Money (Account[4] to Account[5]): Invalid', async () => {
		const sender = accounts[4];
		const receiver = accounts[5];

		const senderStartingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 1000;
		await TransactionManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await UserManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await UserManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
	});

	it('View Transaction (Account[4] to Account[5]): Invalid', async () => {
		var senderStart = accounts[4];
		var receiverStart = accounts[5];

		var temp = await TransactionManagerInstance.getTransactionJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});	
	*/
});
