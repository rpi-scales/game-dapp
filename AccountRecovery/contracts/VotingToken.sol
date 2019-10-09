pragma solidity >=0.4.0 <0.7.0;

contract VotingToken {

	address voter;

	bool public vote;
	bool public  eligible;
	bool public voted;

	event Vote(address indexed _voter, bool _choice);

	constructor(address _voter) public {
		voter = _voter;
		vote = false;
		eligible = true;
		voted = false;
	}

	function CastVote(address from, bool choice) public {
		require(voter == from, "Sent from the wrong voter");
		require(eligible == true, "Not an eligible voter");
		require(voted == false, "Already Voted");
		vote = choice;
		eligible = false;
		voted = true;
		emit Vote(voter, choice);
	}
}
