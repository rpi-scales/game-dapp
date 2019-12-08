const UserManager = artifacts.require("UserManager");
var UMI;			// UserManagerInstance

contract('UserManager', (accounts) => {
	var users = accounts.slice();
	users.shift();

	it('Constructor', async () => {
		UMI = await UserManager.deployed(users);
	});	

	it('Getters', async () => {
		var balance = (await UMI.getUserBalance(users[0])).toNumber();
		assert.equal(balance, 0, "Wrong Balance");
	});

	it('Change Veto Time', async () => {
		await UMI.changeVetoTime(1, {from: users[0]});
	});
});
