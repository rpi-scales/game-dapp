const Manager = artifacts.require("Manager");

var ManagerInstance;

function Transaction(sender, receiver, amount) {
    this.sender = sender;
    this.receiver = receiver;
    this.amount = amount;
}

contract('Manager', (accounts) => {

	it('Constructor', async () => {
		ManagerInstance = await Manager.deployed(accounts);
	});	

	it('Getters', async () => {
		var balance = (await ManagerInstance.getUserBalance(accounts[0])).toNumber();
		assert.equal(balance, 100, "Wrong Balance");

		var ID = await ManagerInstance.getUserID(accounts[0]);
		assert.equal(ID, accounts[0], "Wrong ID");
	});	

	it('Send Money (Account 1 to Account 2): Valid', async () => {
		const sender = accounts[0];
		const receiver = accounts[1];

		const senderStartingBalance = (await ManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await ManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await ManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await ManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await ManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");

	});	

	it('View Transaction (Account 1 to Account 2)', async () => {
		var senderStart = accounts[0];
		var receiverStart = accounts[1];

		var temp = await ManagerInstance.getTransactionsJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});

	it('Send Money (Account 3 to Account 4): Valid', async () => {
		const sender = accounts[2];
		const receiver = accounts[3];

		const senderStartingBalance = (await ManagerInstance.getUserBalance(sender)).toNumber();
		const receiverStartingBalance = (await ManagerInstance.getUserBalance(receiver)).toNumber();

		const amount = 10;
		await ManagerInstance.MakeTransaction(receiver, amount, { from: sender });

		const senderEndingBalance = (await ManagerInstance.getUserBalance(sender)).toNumber();
		const receiverEndingBalance = (await ManagerInstance.getUserBalance(receiver)).toNumber();


		assert.equal(senderEndingBalance, senderStartingBalance - amount, "Amount wasn't correctly taken from the sender");
		assert.equal(receiverEndingBalance, receiverStartingBalance + amount, "Amount wasn't correctly sent to the receiver");

	});	

	it('View Transaction (Account 3 to Account 4)', async () => {
		var senderStart = accounts[2];
		var receiverStart = accounts[3];

		var temp = await ManagerInstance.getTransactionsJS(senderStart, receiverStart, 0);
		var transactionOne = new Transaction(temp[0], temp[1], temp[2]);

		var sender = transactionOne.sender;
		assert.equal(sender, senderStart, "Wrong sender");

		const receiver = transactionOne.receiver;
		assert.equal(receiver, receiverStart, "Wrong receiver");

		const amount = (transactionOne.amount).toNumber();
		assert.equal(amount, 10, "Wrong amount");
	});
});

