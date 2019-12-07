/* VotingToken.sol */

pragma solidity >=0.4.0 <0.7.0;

/* <Summary> 
	This library repersents a voting token. This is used to cast votes.
*/

library VotingToken {

	struct Token {
		uint votedTime;							// The time when the voter votes
		bool vote;								// The decision of the voter
		bool voted;								// If the voter has voted
	}

	event Vote(address indexed _voter, bool _choice); // Voting Event

	// Casting a vote
	function CastVote(Token storage self, address _voter, bool choice) external {

		// Check if the voter has already voted
		require(self.voted == false, "Already Voted");

		self.vote = choice;					// Set the voters vote
		self.voted = true;					// The voter has voted
		self.votedTime = block.timestamp;	// Set the time required to vote
		emit Vote(_voter, choice);
	}

	// Get if the voter voted
	function getVoted(Token storage self) external view returns (bool) {
		return self.voted;
	}

	// Get what the voter voted
	function getVote(Token storage self) external view returns (bool) {
		return self.vote;
	}

	// Get how long it took the voter to vote
	function getVotedTime(Token storage self) external view returns (uint) {
		return self.votedTime;
	}

}
