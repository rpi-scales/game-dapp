const VotingToken = artifacts.require("VotingToken");


module.exports = (deployer, network, accounts) => {
	const oldAccount = accounts.shift();
	const newAccount = accounts.shift();
	deployer.deploy(VotingToken, accounts, oldAccount, newAccount);
};
