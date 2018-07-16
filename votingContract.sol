pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with

contract Voting {
  /* mapping field below is equivalent to an associative array or hash.
  The key of the mapping is candidate name stored as type bytes32 and value is
  an unsigned integer to store the vote count
  */
  mapping (bytes32 => uint8) public votesReceived;
  /* The same logic applies to this mapping variable: it tracks which address
  has voted for which candidate (bytes32) throughout the voting */
  mapping (address => bytes32) public votes;
  /* This address specifies the owner of the contract in order to restrict access
  to certain contract functions*/
  address owner;
  /* Boolean to verify if voting is still active */
  bool votingActive = true;

  /* Events can be emitted by functions in order to notify listener (off-chain)
  applications of the occurrence of a certain event */
  event Print(bytes32[] _name);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /* Solidity doesn't let you pass in an array of strings in the constructor (yet).
  We will use an array of bytes32 instead to store the list of candidates
  */
  bytes32[] public candidateList;
  /* Adress array to store all addresses that have participated in the voting.*/
  address[] public voters;

  /* This is the constructor which will be called once when you
  deploy the contract to the blockchain. When we deploy the contract,
  we will pass an array of candidates who will be contesting in the election.
  In recent version of Solidity the constructor has been replaced by the
  contract name without function keyword: Voting(...) - equivalent to Java syntax.
  */
  constructor(bytes32[] candidateNames) public {
    owner = msg.sender;
    candidateList = candidateNames;
  }

  /* Getter function that returns candidate list. */
  function getCandidateList() public constant returns (bytes32[]) {
      return candidateList;
  }

  /* Getter function that returns contract owner address */
  function getOwner() public constant returns (address) {
      return owner;
  }

  /* Getter function that returns the number of candidates */
  function getCount() public constant returns (uint256) {
      return candidateList.length;
  }

  function getBalance() public constant returns (uint256) {
      return address(this).balance;
  }

  //Function that adds candidate to candidate list. Can only be called by owner.
  function addCandidate(bytes32 candidate) onlyOwner public returns (bool) {
      candidateList.push(candidate);
      return true;
  }

  // This function returns the total votes a candidate has received so far.
  function totalVotesFor(bytes32 candidate) view public returns (uint8) {
    require(validCandidate(candidate));
    return votesReceived[candidate];
  }

  // This function increments the vote count for the specified candidate. This
  // is equivalent to casting a vote.
  function voteForCandidate(bytes32 candidate) public payable  {
    require(msg.value == 1 ether);
    require(validCandidate(candidate));
    require(votes[msg.sender] == 0x0);
    voters.push(msg.sender);
    votes[msg.sender] = candidate;
    votesReceived[candidate] += 1;
  }

  // This function checks if the provided candidate is element of the candidate
  // list and returns a boolean.
  function validCandidate(bytes32 candidate) view public returns (bool) {
    for(uint i = 0; i < candidateList.length; i++) {
      if (candidateList[i] == candidate) {
        return true;
      }
    }
    return false;
  }

  // Function to close voting and handle payout. Can only be called by the owner.
  function closeVoting() onlyOwner public returns (bytes32) {
      require(votingActive);
      uint winningVotes = 0;
      bytes32 winningCandidate;
      for (uint p = 0; p < candidateList.length; p++) {
          if (votesReceived[candidateList[p]] > winningVotes) {
              winningVotes = votesReceived[candidateList[p]];
              winningCandidate = candidateList[p];
          }
      }
      uint prize = (address(this).balance) / (winningVotes);
      for (uint x = 0; x < voters.length; x++) {
          if(votes[voters[x]] == winningCandidate) {
              require(address(this).balance >= prize);
              voters[x].transfer(prize);
          }
      }
      votingActive = false;
      return winningCandidate;
  }
}
