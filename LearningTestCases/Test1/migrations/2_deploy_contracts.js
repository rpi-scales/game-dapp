const Coin = artifacts.require("Coin");
const GameObject = artifacts.require("GameObject");


module.exports = function(deployer) {
	deployer.deploy(Coin);
	deployer.deploy(GameObject);
};
