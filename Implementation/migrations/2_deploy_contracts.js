const UserManager = artifacts.require("UserManager");
const TransactionManager = artifacts.require("TransactionManager");
const ProposalManager = artifacts.require("ProposalManager");
const ProposalCreator = artifacts.require("ProposalCreator");

const set = artifacts.require("Set");
const votingToken = artifacts.require("VotingToken");
const transactionDataSet = artifacts.require("TransactionDataSet");


module.exports = (deployer, network, accounts) => {
	accounts.shift();

	deployer.deploy(set);
	deployer.deploy(votingToken);
	deployer.deploy(transactionDataSet);

	deployer.link(set, ProposalCreator);
	deployer.link(votingToken, ProposalCreator);
	deployer.link(transactionDataSet, ProposalCreator);

	deployer.deploy(UserManager, accounts)
	.then(() => deployer.deploy(ProposalManager, UserManager.address))
	.then(() => deployer.deploy(TransactionManager, UserManager.address, ProposalManager.address))
	.then(() => deployer.deploy(ProposalCreator, UserManager.address, TransactionManager.address, ProposalManager.address))
};
