pragma solidity ^0.4.23;

contract Voting_Campaign {

  address  private owner;

  // Use NRIC (its digits only) to keep track of candidate  
  struct Candidate {
    string  name;
    string  ipcsHash;
    uint    votesReceived;
  }
  mapping(uint => Candidate) private candidates;

  // To keep track of campaing as a whole
  uint  private totalRegisteredVoter;
  uint  private totalReceivedVote;
  uint  private campaignStatus; // 0: configure, 1: voting period, 2: closed
  uint  private campaignStartTime; // Epoch since 1-1-1970
  uint  private campaingDuration; // in second
  Candidate[] private candidatesArray;
  
  // Use NRIC (its digits only) to keep track of voter
  struct Voter {
    string  name;
    bool    hasVoted;
  }
  mapping(uint => Voter) private voters;
  
  constructor() public {
    owner = msg.sender;

    totalRegisteredVoter = 0;
    totalReceivedVote = 0;
    campaignStatus = 0;
    campaignStartTime = 0;
    campaingDuration = 0;
  }

  function setDuration(uint durationSecond_) public returns (bool) {
    require(msg.sender == owner);
    require(campaignStatus == 0);

    campaingDuration = durationSecond_;
    return true;
  }
  
  function startCampaign() public returns (bool) {
    require(msg.sender == owner);
    require(campaignStatus == 0);
    
    campaignStatus = 1;
    campaignStartTime = block.timestamp;

    return true;
  }
  
  function getCampaignStatus() public returns (uint) {
    if (block.timestamp > campaignStartTime + campaingDuration) {
      campaignStatus = 2;
    }
    return campaignStatus;
  }
  
  function getRemainingCampaignSecond() view public returns (uint) {
    require(campaignStatus == 1);
    if (campaignStatus == 2) {
      return 0;
    }
    else {
      return campaignStartTime + campaingDuration - block.timestamp;
    }
  }

  function getTotalRegisteredVoter() view public returns (uint) {
    return totalRegisteredVoter;
  }
  
  function getTotalReceivedVote() view public returns (uint) {
    return totalReceivedVote;
  }
  
  function getCandidateCount() view public returns (uint) {
    return candidatesArray.length;
  }

  function getCandidateByIndex(uint index_) view public 
    returns (string, string, uint) {
    require(index_ < candidatesArray.length);
    
    return (candidatesArray[index_].name,
            candidatesArray[index_].ipcsHash,
            candidatesArray[index_].votesReceived);
  }

  function addCandidate(uint   nric_,
                        string name_, 
                        string ipcsHash_) public returns (bool) {
    require(msg.sender == owner);
    require(campaignStatus == 0);
    
    Candidate storage c = candidates[nric_];
    c.name = name_;
    c.ipcsHash = ipcsHash_;
    c.votesReceived = 0;
    
    candidatesArray.push(c);
    
    return true;
  }
  
  function updateCandidateByIndex(uint   index_,
                                  string name_,
                                  string ipcsHash_) public returns (bool) {
    require(msg.sender == owner);
    require(campaignStatus == 0);
    require(index_ < candidatesArray.length);
    
    Candidate storage c = candidatesArray[index_];
    c.name = name_;
    c.ipcsHash = ipcsHash_;
  }
  
  function addVoter(uint   nric_,
                    string name_) public returns (bool) {
    require(msg.sender == owner);
    require(campaignStatus == 0);
    
    Voter storage v = voters[nric_];
    v.name = name_;
    v.hasVoted = false;
    totalRegisteredVoter++;
    
    return true;
  }

  function voteCandidatebyIndex(uint index_, uint voterNric_) public 
    returns (bool) {
    require(voters[voterNric_].hasVoted == false);
    require(campaignStatus == 1);
    
    candidatesArray[index_].votesReceived++;
    voters[voterNric_].hasVoted = true;
    
    totalReceivedVote++;
    
    return true;
  }

/*  
  function test() public returns (bool) {
    addCandidate(0, "Yoong", "YYYY");
    addCandidate(1, "Wong" , "WWWW");
    addCandidate(2, "Tan"  , "TTTT");
    
    addVoter(10, "Voter  1");
    addVoter(11, "Voter  2");
    addVoter(12, "Voter  3");
    addVoter(13, "Voter  4");
    addVoter(14, "Voter  5");
    addVoter(15, "Voter  6");
    addVoter(16, "Voter  7");
    addVoter(17, "Voter  8");
    addVoter(18, "Voter  9");
    addVoter(19, "Voter 10");
    
    setDuration(5 * 60); // 5 minutes
    startCampaign();
    
    voteCandidatebyIndex(0, 10);
    voteCandidatebyIndex(0, 11);
    voteCandidatebyIndex(0, 12);
    voteCandidatebyIndex(0, 13);
    voteCandidatebyIndex(0, 14);
    voteCandidatebyIndex(1, 15);
    voteCandidatebyIndex(1, 16);
    voteCandidatebyIndex(1, 17);
    voteCandidatebyIndex(2, 18);
    voteCandidatebyIndex(2, 19);
  }
*/  
}
