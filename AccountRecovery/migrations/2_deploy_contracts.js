const VotingToken = artifacts.require("VotingToken");
const Manager = artifacts.require("Manager");

module.exports = (deployer, network, accounts) => {
	deployer.deploy(Manager, accounts);

	const oldAccount = accounts.shift();
	const newAccount = accounts.shift();
	deployer.deploy(VotingToken, accounts, oldAccount, newAccount);
};