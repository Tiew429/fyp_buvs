// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // store admin address while this contract deployed
    address public admin;

    constructor() {
        admin = msg.sender;
    }


    //----------
    // STRUCTS
    //----------

    struct VotingEvent {
        bytes32 eventID; // store unique event id, e.g., "VE-001" in bytes32
        string title; // short title for the event
        uint256 startDate; // unix timestamp for event start date
        uint256 endDate; // unix timestamp for event end date
        address createdBy; // blockchain address of the event creator
        uint8 status; // enum index (0: available, 1: deprecated)
        address[] candidates; // list of candidates' addresses
        address[] voters; // list of voters' addresses (voters)
    }

    struct Candidate {
        bytes32 candidateID; // store unique candidate id, e.g, "CAND-001" in bytes32
        address walletAddress; // candidate's blockchain address
        uint256 votesReceived; // number of votes received
    }

    struct Vote {
        address votes; // voter's blockchain address
        bytes32 candidateID; // vote receiver's id / candidate's idt
        uint256 timestamp; // timestamp when the vote was cast
    }

    //----------
    // MAPPINGS
    //----------

    // mapping to store voting events by their eventID.
    mapping(bytes32 => VotingEvent) public votingEvents;

    // mapping to track whether a voter (by address) has already voted
    // nested mapping: event ID => (voter address => has voted flag)
    mapping(bytes32 => mapping(address => bool)) public hasVotedByEvent;

    // mapping to store the votes with candidate address by voting event id
    mapping(bytes32 => Vote[]) public voteByEvent;

    // mapping to store candidates details by their addresses
    mapping(address => Candidate) public candidates;

    // Additional mappings for candidate management
    mapping(bytes32 => mapping(bytes32 => Candidate)) public candidatesByEvent; // eventID => candidateID => Candidate
    mapping(bytes32 => bytes32[]) public candidateIDsByEvent; // eventID => array of candidateIDs
    
    // Mapping for vote counts
    mapping(bytes32 => mapping(bytes32 => uint256)) public voteCountsByCandidate; // eventID => candidateID => vote count
    
    // Mapping for voter participation
    mapping(bytes32 => mapping(address => bool)) public hasVoted; // eventID => voter address => has voted

    //----------
    // ARRAYS
    //----------

    // array to record the vote history
    Vote[] public votesHistory;

    // array to record the list of created voting event IDs
    bytes32[] private votingEventIDsList;

    //----------
    // EVENTS
    //----------

    event VotingEventCreate(bytes32 indexed eventID);
    event VotingEventUpdate(bytes32 indexed eventID);
    event VotingEventRemove(bytes32 indexed eventID);
    event CandidateAssign(bytes32 indexed eventID, address candidate);
    event CandidateRemove(bytes32 indexed eventID, address candidate);
    event VoterAdd(bytes32 indexed eventID, address student);
    event VoterRemove(bytes32 indexed eventID, address student);
    event VoteCast(bytes32 indexed eventID, address indexed voter, bytes32 candidateID);

    //--------------------
    // GETTER FUNCTIONS
    //--------------------

    // retrieve available voting event id list
    function getVotingEventIDs() public view returns (string[] memory) {
        string[] memory votingEventIDs = new string[](votingEventIDsList.length);
        for (uint256 i = 0; i < votingEventIDsList.length; i++) {
            votingEventIDs[i] = bytes32ToString(votingEventIDsList[i]);
        }
        return votingEventIDs;
    }

    // retrieve avaialble voting event
    function getVotingEvent(string memory _eventID) public view returns (
        string memory eventID,
        string memory title,
        uint256 startDate,
        uint256 endDate,
        address createdBy,
        uint8 status,
        address[] memory candidateList,
        address[] memory voterList
    ) {
        VotingEvent memory votingEvent = votingEvents[stringToBytes32(_eventID)];
        return (
            _eventID,
            votingEvent.title,
            votingEvent.startDate,
            votingEvent.endDate,
            votingEvent.createdBy,
            votingEvent.status,
            votingEvent.candidates,
            votingEvent.voters
        );
    }

    // get candidate details
    function getCandidateDetails(
        string memory _eventIDStr,
        string memory _candidateIDStr
    ) public view returns (
        address walletAddress,
        uint256 votesReceived
    ) {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        bytes32 _candidateID = stringToBytes32(_candidateIDStr);
        
        Candidate memory candidate = candidatesByEvent[_eventID][_candidateID];
        return (
            candidate.walletAddress,
            candidate.votesReceived
        );
    }

    // get all candidates for an event
    function getCandidatesForEvent(string memory _eventIDStr) public view returns (bytes32[] memory) {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        return candidateIDsByEvent[_eventID];
    }

    // get vote results for an event
    function getVoteResults(string memory _eventIDStr) public view returns (bytes32[] memory candidateIDs, uint256[] memory voteCounts) {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        bytes32[] memory _candidates = candidateIDsByEvent[_eventID];
        uint256[] memory votes = new uint256[](_candidates.length);

        for (uint256 i = 0; i < _candidates.length; i++) {
            votes[i] = voteCountsByCandidate[_eventID][_candidates[i]];
        }

        return (_candidates, votes);
    }

    //--------------------
    // SETTER FUNCTIONS
    //-------------------

    // create a new voting event with empty candidates and  voters list
    function createVotingEvent(
        string memory _eventIDStr,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate
    ) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);

        // ensure the event doesn't already exist (using empty eventID as indicator)
        require(votingEvents[_eventID].eventID == bytes32(0), "Voting Event already existed.");

        VotingEvent memory newEvent = VotingEvent({
            eventID: _eventID,
            title: _title,
            startDate: _startDate,
            endDate: _endDate,
            createdBy: msg.sender,
            status: 0, // available by default
            candidates: new address[](0),
            voters: new address[](0)
        });

        // store the event in the mapping
        votingEvents[_eventID] = newEvent;
        // store event id into array
        votingEventIDsList.push(_eventID);

        // emit creation event
        emit VotingEventCreate(_eventID);
    }

    // update an existing voting event only the creator and admin can update, and only if the event hasn't started yet
    function updateVotingEvent(
        string memory _eventIDStr,
        string memory _title,
        uint256 _startDate,
        uint256 _endDate,
        uint8 _status
    ) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        VotingEvent storage votingEvent = votingEvents[_eventID];

        require(votingEvent.eventID != bytes32(0), "Voting event does not exist");
        require(msg.sender == votingEvent.createdBy || msg.sender == admin, "Only event creator can update");
        require(block.timestamp < votingEvent.startDate || msg.sender == admin, "Event already started, cannot update");

        // update event details
        votingEvent.title = _title;
        votingEvent.startDate = _startDate;
        votingEvent.endDate = _endDate;
        votingEvent.status = _status;

        // emit update event
        emit VotingEventUpdate(_eventID);
    }

    // remove an existing voting event only the creator and admin can remove, and only if the event hasn't started yet
    function removeVotingEvent(string memory _eventIDStr) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        VotingEvent storage votingEvent = votingEvents[_eventID];

        require(votingEvent.eventID != bytes32(0), "Voting event does not exist");
        require(msg.sender == votingEvent.createdBy || msg.sender == admin, "Only event creator can remove");
        require(block.timestamp < votingEvent.startDate || msg.sender == admin, "Event already started, cannot remove");

        // change voting event status to deprecated (1)
        votingEvents[_eventID].status = 1;

        // emit removal event
        emit VotingEventRemove(_eventID);
    }

    // cast a vote for a candidate in a specific voting event
    function castVote(
        string memory _eventIDStr,
        string memory _candidateIDStr
    ) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        bytes32 _candidateID = stringToBytes32(_candidateIDStr);
        VotingEvent storage votingEvent = votingEvents[_eventID];

        require(votingEvent.eventID != bytes32(0), "Voting event does not exist");
        require(!hasVoted[_eventID][msg.sender], "Already voted in this event");
        require(block.timestamp >= votingEvent.startDate && block.timestamp <= votingEvent.endDate, "Voting not active");
        require(msg.sender != votingEvent.createdBy && msg.sender != admin, "Voting event creator and the admin cannot vote");

        // Check if candidate exists
        require(candidatesByEvent[_eventID][_candidateID].walletAddress != address(0), "Candidate does not exist");

        // Check if msg.sender is a candidate in this event
        bool isCandidate = false;
        for (uint256 i = 0; i < votingEvent.candidates.length; i++) {
            if (votingEvent.candidates[i] == msg.sender) {
                isCandidate = true;
                break;
            }
        }
        require(!isCandidate, "Candidate cannot vote in this event");

        // Record vote
        Vote memory newVote = Vote({
            votes: msg.sender,
            candidateID: _candidateID,
            timestamp: block.timestamp
        });

        // Update vote counts and records
        voteCountsByCandidate[_eventID][_candidateID]++;
        candidatesByEvent[_eventID][_candidateID].votesReceived++;
        hasVoted[_eventID][msg.sender] = true;
        votesHistory.push(newVote);
        voteByEvent[_eventID].push(newVote);
        votingEvent.voters.push(msg.sender);

        emit VoteCast(_eventID, msg.sender, _candidateID);
    }

    // add candidates to a voting event
    function addCandidates(
        string memory _eventIDStr,
        string[] memory _candidateIDStrs,
        address[] memory _walletAddresses
    ) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        VotingEvent storage votingEvent = votingEvents[_eventID];

        require(votingEvent.eventID != bytes32(0), "Voting event does not exist");
        require(msg.sender == votingEvent.createdBy || msg.sender == admin, "Only event creator can add candidate");
        require(block.timestamp < votingEvent.startDate || msg.sender == admin, "Event already started, cannot add candidate");
        require(_candidateIDStrs.length == _walletAddresses.length, "Candidate IDs and wallet addresses count mismatch");
        require(_candidateIDStrs.length > 0, "No candidates provided");

        for (uint256 i = 0; i < _candidateIDStrs.length; i++) {
            bytes32 _candidateID = stringToBytes32(_candidateIDStrs[i]);
            address walletAddress = _walletAddresses[i];

            require(walletAddress != address(0), "Invalid wallet address");
            require(_candidateID != bytes32(0), "Invalid candidate ID");
            require(candidatesByEvent[_eventID][_candidateID].walletAddress == address(0), "Candidate already exists");
            require(walletAddress != msg.sender && walletAddress != admin, "Voting event creator and admin cannot participate in the event");

            Candidate memory newCandidate = Candidate({
                candidateID: _candidateID,
                walletAddress: walletAddress,
                votesReceived: 0
            });

            candidatesByEvent[_eventID][_candidateID] = newCandidate;
            candidateIDsByEvent[_eventID].push(_candidateID);
            candidates[walletAddress] = newCandidate;
            votingEvent.candidates.push(walletAddress);

            // emit candidate assign event
            emit CandidateAssign(_eventID, walletAddress);
        }
    }

    // remove candidate from a voting event
    function removeCandidate(string memory _eventIDStr, address _candidate) public {
        bytes32 _eventID = stringToBytes32(_eventIDStr);
        VotingEvent storage votingEvent = votingEvents[_eventID];

        require(votingEvent.eventID != bytes32(0), "Voting event does not exist");
        require(msg.sender == votingEvent.createdBy || msg.sender == admin, "Only event creator can remove candidate");
        require(block.timestamp < votingEvent.startDate || msg.sender == admin, "Event already started, cannot remove candidate");

        bool found = false;
        for (uint256 i = 0; i < votingEvent.candidates.length; i++) {
            if (votingEvent.candidates[i] == _candidate) {
                // swap with the last element and remove.
                votingEvent.candidates[i] = votingEvent.candidates[
                    votingEvent.candidates.length - 1
                ];
                votingEvent.candidates.pop();
                found = true;
                break;
            }
        }
        require(found, "Candidate not found");

        // emit candidate removal event
        emit CandidateRemove(_eventID, _candidate);
    }

    //--------------------
    //HELPER FUNCTIONS
    //--------------------

    // Helper function to convert string to bytes32
    function stringToBytes32(string memory _string) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(_string);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_string, 32))
        }
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < bytesArray.length; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
