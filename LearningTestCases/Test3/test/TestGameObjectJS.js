const GameObject = artifacts.require("GameObject");

contract('GameObject', (accounts) => {
	it('should put 0 GameObject in the first account', async () => {
		const gameObjectInstance = await GameObject.deployed();
		const balance = (await gameObjectInstance.getBalance.call(accounts[0])).toNumber();
		
		assert.equal(balance.valueOf(), 0, "0 wasn't in the first account");
	});

});

