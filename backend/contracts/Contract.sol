// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MyContract {
        struct Campaign {
        address owner;
        string title;
        string description;
        uint target;
        uint deadline;
        uint amountCollected;
        string image;
        address[] donators;
        uint[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0; // # of campaigns created to allocate IDs

    function createCampaign(address _owner, string memory _title, string memory _description, 
    uint256 _target, uint256 _deadline, string memory _image) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // test to see if deadline is correct
        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    /* We will send cryptocurrency through this function hence "payable" */
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value; // sending from frontend

        Campaign storage campaign = campaigns[_id]; // campaigns refers to the mapping at the top

        campaign.donators.push(msg.sender); // push the address of the person that donated
        campaign.donations.push(amount); // push the amount 

        (bool sent,) = payable(campaign.owner).call{value: amount}(""); // boolean to check whether transaction has been sent or not

        if (sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations); // returns array from campaigns mapping
    }

    function getCampaigns() public view returns(Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns); // new empty array variable with empty elements of actual campaigns

        /* populate the array */
        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }
        return allCampaigns;
     }
}