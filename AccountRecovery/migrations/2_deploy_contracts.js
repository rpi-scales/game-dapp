const UserManager = artifacts.require("UserManager");
const TransactionManager = artifacts.require("TransactionManager");
const ProposalManager = artifacts.require("ProposalManager");

const set = artifacts.require("Set");


module.exports = (deployer, network, accounts) => {
	deployer.deploy(set);
	deployer.link(set, ProposalManager);

	deployer.deploy(UserManager, accounts)
	.then(() => deployer.deploy(TransactionManager, UserManager.address))
	.then(() => deployer.deploy(ProposalManager, UserManager.address, TransactionManager.address))
};
