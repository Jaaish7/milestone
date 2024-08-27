// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MilestoneTracker {
    enum MilestoneStatus { NotStarted, InProgress, Completed }

    struct Milestone {
        uint256 id;
        string description;
        MilestoneStatus status;
        uint256 completionDate;
    }

    mapping(address => Milestone[]) public userMilestones;
    mapping(uint256 => address) public milestoneOwners;
    uint256 public milestoneCounter;

    event MilestoneCreated(address indexed user, uint256 id, string description);
    event MilestoneStatusUpdated(address indexed user, uint256 id, MilestoneStatus status, uint256 completionDate);

    // Create a new milestone
    function createMilestone(string calldata _description) external {
        milestoneCounter++;
        Milestone memory newMilestone = Milestone({
            id: milestoneCounter,
            description: _description,
            status: MilestoneStatus.NotStarted,
            completionDate: 0
        });

        userMilestones[msg.sender].push(newMilestone);
        milestoneOwners[milestoneCounter] = msg.sender;

        emit MilestoneCreated(msg.sender, milestoneCounter, _description);
    }

    // Update the status of a milestone
    function updateMilestoneStatus(uint256 _milestoneId, MilestoneStatus _status) external {
        require(milestoneOwners[_milestoneId] == msg.sender, "You are not the owner of this milestone");
        require(_status != MilestoneStatus.NotStarted, "Milestone cannot be marked as NotStarted");

        Milestone[] storage milestones = userMilestones[msg.sender];
        for (uint256 i = 0; i < milestones.length; i++) {
            if (milestones[i].id == _milestoneId) {
                milestones[i].status = _status;
                if (_status == MilestoneStatus.Completed) {
                    milestones[i].completionDate = block.timestamp;
                }
                emit MilestoneStatusUpdated(msg.sender, _milestoneId, _status, milestones[i].completionDate);
                return;
            }
        }
        revert("Milestone not found");
    }

    // Get milestones for a specific user
    function getUserMilestones(address _user) external view returns (Milestone[] memory) {
        return userMilestones[_user];
    }

    // Get a specific milestone details
    function getMilestone(uint256 _milestoneId) external view returns (Milestone memory) {
        address owner = milestoneOwners[_milestoneId];
        Milestone[] memory milestones = userMilestones[owner];
        for (uint256 i = 0; i < milestones.length; i++) {
            if (milestones[i].id == _milestoneId) {
                return milestones[i];
            }
        }
        revert("Milestone not found");
    }
}
