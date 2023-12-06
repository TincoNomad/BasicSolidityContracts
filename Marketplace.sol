//SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract marketPlace is Ownable{

    mapping(uint => uint) values;
    mapping(uint=> address) bidder;
    IERC721 achievements;
    IERC20 token;

    constructor(address initialOwner, address tokenContract, address achievementContract) Ownable(initialOwner) {
        achievements = IERC721(achievementContract);
        token = IERC20(tokenContract);       
    }

    function post (uint tokenId, uint value) public {
        require(values[tokenId]== 0);
        require(value > 0);

        require(achievements.getApproved(tokenId) == address(this));

        values[tokenId] = value;
        bidder[tokenId] = msg.sender;
    }

    function finalization (uint tokenId) public onlyOwner {
        require(values[tokenId] > 0);
        require(token.allowance(bidder[tokenId],address(this)) > values[tokenId]);
        require(achievements.getApproved(tokenId) == address(this));

        token.transferFrom(bidder[tokenId], achievements.ownerOf(tokenId), values[tokenId]);
        achievements.safeTransferFrom(achievements.ownerOf(tokenId), bidder[tokenId], tokenId);
        values[tokenId] = 0;
    }

    function offer(uint tokenId, uint amount) public {
        require(values[tokenId] > 0);
        require(amount > values[tokenId]);
        require(token.allowance(msg.sender, address(this)) > amount);

        bidder[tokenId] = msg.sender;
        values[tokenId] = amount;
    } 

    //the below funtion is for use a regular marketplace insted of an auction, as the function above.
    //
    //function buy (uint tokenId) public {
        //require(values[tokenId] != 0);
        //require(token.allowance(msg.sender, address(this)) >= values[tokenId]);
        //require(achievements.getApproved(tokenId) == address(this));

        //token.transferFrom(msg.sender, achievements.ownerOf(tokenId), values[tokenId]);
        //achievements.safeTransferFrom(achievements.ownerOf(tokenId), msg.sender, tokenId);
        //values[tokenId] = 0;
    //}
}