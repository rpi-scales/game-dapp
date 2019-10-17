const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

contract('UserManager', (accounts) => {

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(accounts);
	});	

	it('Getters', async () => {
		var balance = (await UserManagerInstance.getUserBalance(accounts[0])).toNumber();
		assert.equal(balance, 1000, "Wrong Balance");

		var ID = await UserManagerInstance.getUserID(accounts[0]);
		assert.equal(ID, accounts[0], "Wrong ID");
	});
});
