const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

contract('UserManager', (accounts) => {
	accounts.shift();

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
	});	

	it('Getters', async () => {
		var balance = (await UserManagerInstance.getUserBalance(accounts[0])).toNumber();
		assert.equal(balance, 0, "Wrong Balance");
	});

	it('Change Veto Time', async () => {
		await UserManagerInstance.changeVetoTime(1, {from: accounts[0]});
	});
});
