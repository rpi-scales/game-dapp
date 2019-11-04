const UserManager = artifacts.require("UserManager");
var UserManagerInstance;

contract('UserManager', (accounts) => {
	var users = accounts.slice();
	users.shift();

	it('Constructor', async () => {
		UserManagerInstance = await UserManager.deployed(users);
	});	

	it('Getters', async () => {
		var balance = (await UserManagerInstance.getUserBalance(users[0])).toNumber();
		assert.equal(balance, 0, "Wrong Balance");
	});

	it('Change Veto Time', async () => {
		await UserManagerInstance.changeVetoTime(1, {from: users[0]});
	});
});
