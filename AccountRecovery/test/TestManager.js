const Manager = artifacts.require("Manager");
var ManagerInstance;

contract('Manager', (accounts) => {

	it('Create Vote Token', async () => {
		ManagerInstance = await Manager.deployed(accounts);
		var balance = (await ManagerInstance.getUserBalance(0)).toNumber();
		assert.equal(balance, 100, "Wrong Balance");

		var ID = await ManagerInstance.getUserID(0);
		assert.equal(ID, accounts[0], "Wrong");
	});	
});

