const UserManager = artifacts.require("UserManager");
const TransactionManager = artifacts.require("TransactionManager");
const ProposalManager = artifacts.require("ProposalManager");
const ProposalCreator = artifacts.require("ProposalCreator");

const set = artifacts.require("Set");



module.exports = (deployer, network, accounts) => {
	deployer.deploy(set);
	deployer.link(set, ProposalCreator);

	deployer.deploy(UserManager, accounts)
	.then(() => deployer.deploy(ProposalManager, UserManager.address))
	.then(() => deployer.deploy(TransactionManager, UserManager.address, ProposalManager.address))
	.then(() => deployer.deploy(ProposalCreator, UserManager.address, TransactionManager.address, ProposalManager.address))
};
