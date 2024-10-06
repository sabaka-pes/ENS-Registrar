// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ENSRegister2 {
    struct User {
        address oAddr;
        uint timeOfCreation;
        uint price;
        uint yearsRent;
    }

    address public immutable owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner!");
        _; 
    }
    constructor() {
        owner = msg.sender;
    }

    mapping(string => User) public ensOwner;

    uint public totalWithdrawn;

    uint public yearPrice;
    function setYearPrice(uint _newPrice) public onlyOwner {
        yearPrice = _newPrice; // setting a new price for the year (in wei)
    }

    uint public coeff;
    function setCoeff(uint _newCoeff) public onlyOwner {
        coeff = _newCoeff; // setting a new coefficient (in wei)
    }

    // Function for domain registration
    function registerENS(string memory _name, uint _yearsRent) public payable {
        uint totalTime = _yearsRent * 365 * 24 * 60 * 60;

        // Check: the domain must be available for registration
        require((ensOwner[_name].oAddr == address(0)) || (block.timestamp <= ensOwner[_name].timeOfCreation + totalTime), "Domain is already registered.");

        // Checking the validity of the time period for domain registration
        require(_yearsRent >= 1 && _yearsRent <= 10, "Invalid year registration.");

        // Check: the user has paid enough for registration
        require(msg.value >= (yearPrice * _yearsRent), "Not enough ether provided to register domain.");

        ensOwner[_name].oAddr = msg.sender; // domain name assignment
        ensOwner[_name].timeOfCreation = block.timestamp; // time of assignment
        ensOwner[_name].price = yearPrice; // price paid for the domain (per year)
        ensOwner[_name].yearsRent = _yearsRent; // how many years is the domain registration for
    }

    // Function for domain renewal
    function renewRegistration(string memory _name, uint _yearsRent) public payable {
        // Check: Does the domain currently belong to the sender of the transaction
        require(ensOwner[_name].oAddr == msg.sender, "You are not an owner of this domain or it is not yet expired");

        uint renewPrice = ensOwner[_name].price * coeff;
        // Check: Are there enough funds for renewal
        require(msg.value >= (renewPrice * _yearsRent), "Not enough ether provided to extend domain registration.");

        ensOwner[_name].yearsRent += _yearsRent; // how many years is the domain registration for
    }

    function getOwner(string memory _name) public view returns(address, uint) {
        return (ensOwner[_name].oAddr, ensOwner[_name].yearsRent); // return the domain owner and the term
    }
	
	// Function to withdraw all received money
    function withdrawAll() public onlyOwner {   
        uint balanceToSend = address(this).balance; 
        totalWithdrawn += balanceToSend; // amount of funds withdrawn
        payable(owner).transfer(balanceToSend); // withdrawal of all available funds
    }

    // function destroy() public {
    //     selfdestruct(payable(owner));
    // }
}