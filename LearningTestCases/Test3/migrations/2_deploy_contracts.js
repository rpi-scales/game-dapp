const Coin = artifacts.require("Coin");
const GameObject = artifacts.require("GameObject");
const Inventory = artifacts.require("Inventory");


module.exports = function(deployer) {
	deployer.deploy(Coin);
	deployer.deploy(GameObject);
	deployer.deploy(Inventory);
};
