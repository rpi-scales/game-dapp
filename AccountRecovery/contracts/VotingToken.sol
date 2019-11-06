/* VotingToken.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This contract repersents a voting token. This is used to cast votes and view transaction data.
*/

library VotingToken {

	struct Token {
		address oldAccount;						// Address of the old account
		address voter;							// Address of the voter

		uint votedTime;							// The time when the voter votes

		bool vote;								// The decision of the voter
		bool voted;								// If the voter has voted
	}

	event Vote(address indexed _voter, bool _choice); // Voting Event

	// Casting a vote
	function CastVote(Token storage self, bool choice) external {
		// Checks if the voter is allowed to vote
		require(self.voted == false, "Already Voted");
		self.vote = choice;
		self.voted = true;
		self.votedTime = block.timestamp;
		emit Vote(self.voter, choice);
	}

	function getVote(Token storage self) external view returns (bool) {
		return self.vote;
	}

	function getVoted(Token storage self) external view returns (bool) {
		return self.voted;
	}

	function getVotedTime(Token storage self) external view returns (uint) {
		return self.votedTime;
	}

}
