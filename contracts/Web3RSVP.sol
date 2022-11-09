//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
/*
import "hardhat/console.sol";

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
*/

contract Web3RSVP {
    struct CreateEvent {
        bytes32 eventId;
        string eventDataCID;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
   }

   mapping(bytes32 => CreateEvent) public idToEvent;
   
   function createNewEvent(
    uint256 eventTimestamp,
    uint256 deposit,
    uint maxCapacity, 
    string calldata eventDataCID
   ) external{
    //generate an eventID based on other things passed in to generate a hash
    bytes32 eventId = keccak256(
        abi.encodePacked(
            msg.sender,
            address(this),
            eventTimestamp, 
            deposit,
            maxCapacity
        )
    );

    // make sure this id isn't already claimed
    require(idToEvent[eventId].eventTimestamp == 0, "ALREADY REGISTERED");

    address[] memory confirmedRSVPs;
    address[] memory claimedRSVPs;

    // this creates a new CreateEvent struct and adds it to the idToEvent mapping

    idToEvent[eventId] = CreateEvent(
        eventId,
        eventDataCID,
        msg.sender,
        eventTimestamp,
        deposit,
        maxCapacity,
        confirmedRSVPs,
        claimedRSVPs,
        false
    );

   }
   function createNewRSVP(bytes32 eventId) external payable{
    // Look up event from our mapping
    CreateEvent storage myEvent = idToEvent[eventId];

    // Transfer deposit to our contract / require that they send in enough ETH to cover the deposit
    //requirement of this specific event
    require(msg.value == myEvent.deposit, "NOT ENOUGH");

    // Require that the event hasn't already happened (<eventTimestamp)
    require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

    // Make sure event is under max capacity
    require(myEvent.confirmedRSVPs.length < myEvent.maxCapacity, "This event has reached capacity");

    // Require that msg.sender isn't already in myEvent.confirmedRSVPs AKA hasn't already RSVP'd
    for(uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++){
        require(myEvent.claimedRSVPs[i] != msg.sender, "ALREADY CONFIRMED");
    }
    
    myEvent.confirmedRSVPs.push(payable(msg.sender));

   }
}
