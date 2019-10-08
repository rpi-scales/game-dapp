const UserManager = artifacts.require("UserManager");
const TransactionManager = artifacts.require("TransactionManager");
const ProposalManager = artifacts.require("ProposalManager");

module.exports = (deployer, network, accounts) => {
	deployer.deploy(UserManager, accounts)
	.then(() => deployer.deploy(TransactionManager, UserManager.address))
	.then(() => deployer.deploy(ProposalManager, UserManager.address, TransactionManager.address))
};
