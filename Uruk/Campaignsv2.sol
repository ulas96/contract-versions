// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface Uruk {
    function isMember(address _address) external view returns(bool); 
}


contract Campaigns {

    Uruk uruk = Uruk(0x9C4577b3a6E179CbffDD7C6F08d7c0E4478928d8);
    
    struct Participant {
        address participantAddress;
        string[] answers;
        bool isRewarded;
    }

    struct Campaign {
        address creator;
        uint256 id;
        uint256 donation;
        uint256 articleId;
        string[] questions;
        Participant[] participants;
        uint256 maxReward;
        uint256 remainingReward;
    }

    Campaign[] public campaigns;

    function createCampaign(uint256 _donation, uint256 _articleId, string[] memory _questions, uint256 _maxReward) public payable {
        require(uruk.isMember(msg.sender));
        require(_donation >= msg.value );
        uint256 campaignId = campaigns.length + 1;
        Campaign storage newCampaign = campaigns.push();
        newCampaign.creator = msg.sender;
        newCampaign.id = campaignId;
        newCampaign.donation = _donation;
        newCampaign.articleId = _articleId;
        newCampaign.questions = _questions;
        newCampaign.maxReward = _maxReward;
        newCampaign.remainingReward = _donation;
    }
    
    function participateCampaign(uint256 _campaignId, string[] memory _answers) public {
        require(uruk.isMember(msg.sender));
        require(campaigns.length >= _campaignId, "Campaign doesn't exist");
        require(_answers.length == campaigns[_campaignId - 1].questions.length);
        Campaign storage currentCampaign = campaigns[_campaignId - 1];
        Participant memory currentParticipant = Participant(msg.sender, _answers, false);
        currentCampaign.participants.push(currentParticipant);
    }

    function rewardParticipant(uint256 _campaignId, uint256 _participantId) public {
        require(uruk.isMember(msg.sender));
        require(campaigns[_campaignId-1].remainingReward > 0);
        require(campaigns[_campaignId-1].participants.length >= _participantId, "Participant doesn't exist");
        require(campaigns[_campaignId-1].participants[_participantId-1].isRewarded == false, "Participant already rewarded");
        campaigns[_campaignId-1].participants[_participantId-1].isRewarded == true;
        campaigns[_campaignId-1].remainingReward -= campaigns[_campaignId-1].maxReward;
    }

    function claimReward(uint256 _campaignId) public {
        require(uruk.isMember(msg.sender));
        require(campaigns[_campaignId-1].participants.length > 0, "No participants");
        for(uint i = 0; i < campaigns[_campaignId-1].participants.length; i++) {
            if(campaigns[_campaignId-1].participants[i].participantAddress == msg.sender) {
                require(campaigns[_campaignId-1].participants[i].isRewarded == true, "Not rewarded");
                payable(msg.sender).transfer(campaigns[_campaignId-1].maxReward);
            }
        }
    }

    function getCompaigns() public view returns(Campaign[] memory) {
        return campaigns;
    }

}