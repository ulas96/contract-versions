



// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;



contract Uruk {

    struct Member {
        string nickname;
        uint256 memberId;
        address memberAddress;
        uint256 memberSince;
    }

    struct Article {
        address owner;
        uint256 id;
        bytes32 content;
        uint256 timestamp;
        address[] supporters;
        uint256 tip;
        Comment[] comments;
    }

    struct Comment {
        address owner;
        uint256 id;
        bytes32 content;
        uint256 timestamp;
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

    mapping(address => Member) public members;
    mapping(address => Article[]) public articles;
    mapping(address => address[]) public connections;
    address[] public memberAddresses;
    Campaign[] public campaigns;

    function becomeMember(string memory _nickname) public {
            require(members[msg.sender].memberAddress != msg.sender, "Already a member");
        for(uint i = 0; i < memberAddresses.length; i++) {
            require(keccak256(abi.encodePacked(members[memberAddresses[i]].nickname)) != keccak256(abi.encodePacked(_nickname)), "Nickname already taken");
        }
        members[msg.sender] = Member(_nickname, memberAddresses.length + 1, msg.sender, block.timestamp);
        memberAddresses.push(msg.sender);
    }

    function changeNickname (string memory _nickname) public{
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        for(uint i = 0; i < memberAddresses.length; i++) {
            require(keccak256(abi.encodePacked(members[memberAddresses[i]].nickname)) != keccak256(abi.encodePacked(_nickname)), "Nickname already taken");
        }
        members[msg.sender].nickname = _nickname;
    }

    function publishArticle(string memory _article) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        Article storage currentarticle = articles[msg.sender].push();
        currentarticle.owner = msg.sender;
        currentarticle.id = articles[msg.sender].length;
        currentarticle.content = keccak256(abi.encodePacked(_article));
        currentarticle.timestamp = block.timestamp;
        currentarticle.supporters = new address[](0);
        currentarticle.tip = 0;
    }



    function deletearticle(uint256 _articleId) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(articles[msg.sender].length >= _articleId, "article doesn't exist");
        for(uint i = _articleId - 1; i < articles[msg.sender].length - 1; i++) {
            articles[msg.sender][i] = articles[msg.sender][i + 1];
            articles[msg.sender][i].id = i - 1 ;
        }
        articles[msg.sender].pop();
    }

    function editarticle(uint256 _articleId, string memory _newContent) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(articles[msg.sender].length >= _articleId, "article doesn't exist");
        articles[msg.sender][_articleId - 1].content = keccak256(abi.encodePacked(_newContent));
    }


    function supportarticle(address articleOwner, uint256 articleIndex, uint256 _value) public payable {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(_value >= msg.value, "Not enough ether");
        require(articles[articleOwner].length >= articleIndex, "article doesn't exist");
        articles[articleOwner][articleIndex - 1].supporters.push(msg.sender);
        articles[articleOwner][articleIndex - 1].tip += msg.value;
    }

    function addComment(address _articleOwner,uint256 _articleId, string memory _comment) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        Article storage _article = articles[_articleOwner][_articleId - 1];
        Comment memory currentComment = Comment({
    owner: msg.sender, 
    id: _article.comments.length + 1, 
    content: keccak256(abi.encodePacked(_comment)), 
    timestamp: block.timestamp
});
        _article.comments.push(currentComment);
    }

    function deleteComment(address _articleOwner, uint256 _articleId, uint256 _commentId) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(articles[_articleOwner].length >= _articleId, "article doesn't exist");
        require(articles[_articleOwner][_articleId - 1].comments.length >= _commentId, "Comment doesn't exist");
        require(articles[_articleOwner][_articleId - 1].comments[_commentId - 1].owner == msg.sender, "Not the owner of the comment");
        for(uint i = _commentId - 1; i < articles[_articleOwner][_articleId - 1].comments.length - 1; i++) {
            articles[_articleOwner][_articleId - 1].comments[i] = articles[_articleOwner][_articleId - 1].comments[i + 1];
            articles[_articleOwner][_articleId - 1].comments[i].id = i - 1 ;
        }
        articles[_articleOwner][_articleId - 1].comments.pop();

    }

    function connect(address _memberAddress) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(members[_memberAddress].memberAddress == _memberAddress, "Not a member");
        connections[msg.sender].push(_memberAddress);
        connections[_memberAddress].push(msg.sender);
    }

    function disconnect(address _memberAddress) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(members[_memberAddress].memberAddress == _memberAddress, "Not a member");
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


    function createCampaign(uint256 _donation, uint256 _articleId, bytes32[] memory _questions, uint256 _maxReward) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        uint256 campaignId = campaigns.length + 1;
        Campaign memory newCampaign = campaigns.push();
        newCampaign.creator = msg.sender;
        newCampaign.id = campaignId;
        newCampaign.donation = _donation;
        newCampaign.articleId = _articleId;
        newCampaign.questions = _questions;
        newCampaign.participants = new Participant[](0);
        newCampaign.maxReward = _maxReward;
    }

    function participateCampaign(uint256 _campaignId, bytes32[] memory _answers) public {
        require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(campaigns.length >= _campaignId - 1, "Campaign doesn't exist");
        Campaign storage currentCampaign = campaigns[_campaignId - 1];
        Participant memory currentParticipant = Participant(msg.sender, _answers, false);
        currentCampaign.participants.push(currentParticipant);
    }

    function rewardParticipant(uint256 _campaignId, uint256 _participantId) public {
        //require(campaigns[_campaignId-1].creator == msg.sender, "Only creators of the campaign can reward participants");
        require(campaigns[_campaignId-1].remainingReward > 0);
        require(campaigns[_campaignId-1].participants.length >= _participantId, "Participant doesn't exist");
        require(campaigns[_campaignId-1].participants[_participantId-1].isRewarded == false, "Participant already rewarded");
        campaigns[_campaignId-1].participants[_participantId-1].isRewarded == true;
        campaigns[_campaignId-1].remainingReward -= campaigns[_campaignId-1].maxReward;
    }

    function claimReward(uint256 _campaignId) public {
        //require(members[msg.sender].memberAddress == msg.sender, "Not a member");
        require(campaigns[_campaignId-1].participants.length > 0, "No participants");
        for(uint i = 0; i < campaigns[_campaignId-1].participants.length; i++) {
            if(campaigns[_campaignId-1].participants[i].participantAddress == msg.sender) {
                require(campaigns[_campaignId-1].participants[i].isRewarded == true, "Not rewarded");
                payable(msg.sender).transfer(campaigns[_campaignId-1].maxReward);
            }
        }
    }


    function getMember(address _memberAddress) public view returns(Member memory) {
        return members[_memberAddress];
    }

    function getMembers() public view returns(address[] memory) {
        return memberAddresses;
    }

    function getMemberarticles(address _memberAddress) public view returns(Article[] memory) {
        return articles[_memberAddress];

    }

    function getMemberConnections(address _memberAddress) public view returns(address[] memory) {
        return connections[_memberAddress];
    }
}