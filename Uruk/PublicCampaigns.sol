

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


interface Uruk {
    function isMember(address _address) external view returns(bool); 
    function getArticleCount() external view returns(uint256);
}

contract PublicCampaigns {

    Uruk uruk = Uruk(0x4038Ae2072E9b1653EA42B09a7817e8C61f0C995);
    
    struct Participant {
        address participantAddress;
        string[] answers;
        uint256 votes;
        bool isRewarded;
    }

    struct Donation {
        address donatorAddress;
        uint256 donationAmount;
    }

    struct Vote {
        address voterAddress;
        uint256 vote;
    }

    struct PublicCampaign {
        uint256 id;
        uint256 donationDeadline;
        uint256 votingDeadline;
        uint256 articleId;
        string[] questions;
        Participant[] participants;
        Donation[] donations;
        Vote[] votes;
        address[] winners;
        uint256 donation;
        uint256 maxReward;
        uint256 remainingReward;
    }

    PublicCampaign[] public publicCampaigns;

    function createCampaign(uint256 _donationDeadline, uint256 _votingDeadline, uint256 _articleId, string[] memory _questions, uint256 _maxReward) public  {
        require(uruk.isMember(msg.sender));
        require(_donationDeadline > block.timestamp);
        require(_votingDeadline > _donationDeadline);
        require(uruk.getArticleCount() >= _articleId);
        PublicCampaign storage newCampaign = publicCampaigns.push();
        newCampaign.id = publicCampaigns.length;
        newCampaign.donationDeadline = _donationDeadline;
        newCampaign.votingDeadline = _votingDeadline;
        newCampaign.articleId = _articleId;
        newCampaign.questions = _questions;
        newCampaign.maxReward = _maxReward;
        newCampaign.remainingReward = 0;
    }

    function donateCampaign(uint256 _campaignId) external payable {
        require(msg.value > 0);
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId);
        require(publicCampaigns[_campaignId].donationDeadline > block.timestamp);
        publicCampaigns[_campaignId].donations.push(Donation(msg.sender, msg.value));
        publicCampaigns[_campaignId].donation += msg.value;
        publicCampaigns[_campaignId].remainingReward += msg.value;
    }
    
    function participateCampaign(uint256 _campaignId, string[] memory _answers) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns.length >= _campaignId, "Campaign doesn't exist");
        require(_answers.length == publicCampaigns[_campaignId - 1].questions.length);
        PublicCampaign storage currentCampaign = publicCampaigns[_campaignId - 1];
        Participant memory currentParticipant = Participant(msg.sender, _answers,0 , false);
        currentCampaign.participants.push(currentParticipant);
    }

    
    function decideWinners() {

    }

    function claimReward(uint256 _campaignId) public {
        require(uruk.isMember(msg.sender));
        require(publicCampaigns[_campaignId-1].participants.length > 0, "No participants");
        for(uint i = 0; i < publicCampaigns[_campaignId-1].participants.length; i++) {
            if(publicCampaigns[_campaignId-1].participants[i].participantAddress == msg.sender) {
                require(publicCampaigns[_campaignId-1].participants[i].isRewarded == true, "Not rewarded");
                payable(msg.sender).transfer(publicCampaigns[_campaignId-1].maxReward);
            }
        }
    }

    function getCompaigns() public view returns(PublicCampaign[] memory) {
        return publicCampaigns;
    }

}