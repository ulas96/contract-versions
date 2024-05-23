

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface Uruk {
    function isMember(address _address) external view returns(bool);
}


contract Campaigns {

    Uruk urukContract;

    constructor(
        address _urukContract
    ) {
        urukContract = Uruk(_urukContract);
    }
    
    struct Participant {
        address participantAddress;
        bytes32[] answers;
        bool isRewarded;
    }

    struct Campaign {
        address creator;
        uint256 id;
        uint256 donation;
        uint256 articleId;
        bytes32[] questions;
        Participant[] participants;
        uint256 maxReward;
        uint256 remainingReward;
    }

    Campaign[] public campaigns;

        function createCampaign(uint256 _donation, uint256 _articleId, bytes32[] memory _questions, uint256 _maxReward) public payable {
        //require(urukContract.members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(msg.value >= _donation);
        uint256 campaignId = campaigns.length + 1;
        Campaign memory newCampaign = campaigns.push();
        newCampaign.creator = msg.sender;
        newCampaign.id = campaignId;
        newCampaign.donation = _donation;
        newCampaign.articleId = _articleId;
        newCampaign.questions = _questions;
        newCampaign.participants = new Participant[](0);
        newCampaign.maxReward = _maxReward;
        newCampaign.remainingReward = _donation;
    }

    function participateCampaign(uint256 _campaignId, bytes32[] memory _answers) public {
        //require(urukContract.members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(campaigns.length >= _campaignId, "Campaign doesn't exist");
        require(_answers.length == campaigns[_campaignId - 1].questions.length);
        Campaign storage currentCampaign = campaigns[_campaignId - 1];
        Participant memory currentParticipant = Participant(msg.sender, _answers, false);
        currentCampaign.participants.push(currentParticipant);
    }

    function rewardParticipant(uint256 _campaignId, uint256 _participantId) public {
        //require(urukContract.members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(campaigns[_campaignId-1].remainingReward > 0);
        require(campaigns[_campaignId-1].participants.length >= _participantId, "Participant doesn't exist");
        require(campaigns[_campaignId-1].participants[_participantId-1].isRewarded == false, "Participant already rewarded");
        campaigns[_campaignId-1].participants[_participantId-1].isRewarded == true;
        campaigns[_campaignId-1].remainingReward -= campaigns[_campaignId-1].maxReward;
    }

    function claimReward(uint256 _campaignId) public {
        //require(urukContract.members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(campaigns[_campaignId-1].participants.length > 0, "No participants");
        for(uint i = 0; i < campaigns[_campaignId-1].participants.length; i++) {
            if(campaigns[_campaignId-1].participants[i].participantAddress == msg.sender) {
                require(campaigns[_campaignId-1].participants[i].isRewarded == true, "Not rewarded");
                payable(msg.sender).transfer(campaigns[_campaignId-1].maxReward);
            }
        }
    }

}