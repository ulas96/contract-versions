// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface Uruk {
    function isMember(address _address) external view returns(bool); 
}

contract Connections {

    Uruk uruk = Uruk(0x9C4577b3a6E179CbffDD7C6F08d7c0E4478928d8);

    mapping(address => address[]) public connections;

    function connect(address _memberAddress) public {
        require(uruk.isMember(msg.sender));
        connections[msg.sender].push(_memberAddress);
        connections[_memberAddress].push(msg.sender);
    }

    function disconnect(address _memberAddress) public {
        require(uruk.isMember(msg.sender));
        require(uruk.isMember(_memberAddress));
        for(uint i = 0; i < connections[msg.sender].length; i++) {
            if(connections[msg.sender][i] == _memberAddress) {
                for(uint j = i; j < connections[msg.sender].length - 1; j++) {
                    connections[msg.sender][j] = connections[msg.sender][j + 1];
                }
                connections[msg.sender].pop();
            }
        }

        for(uint i = 0; i < connections[_memberAddress].length; i++) {
            if(connections[_memberAddress][i] == msg.sender) {
                for(uint j = i; j < connections[_memberAddress].length - 1; j++) {
                    connections[_memberAddress][j] = connections[_memberAddress][j + 1];
                }
                connections[_memberAddress].pop();
            }
        }
    }

    function getMemberConnections(address _memberAddress) public view returns(address[] memory) {
        return connections[_memberAddress];
    }
}