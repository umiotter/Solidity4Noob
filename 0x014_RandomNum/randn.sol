// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract unsafeRandN{
    // @notice unsafe random number
    function getRandomOnchanin() public view returns(uint256){
        bytes32 randomBytes = keccak256(abi.encodePacked(block.number, msg.sender, blockhash(block.timestamp - 1)));
        return uint256(randomBytes);
    }
}

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract SafeRandomN is VRFConsumerBase {
    bytes32 internal keyHash; // VRF token
    uint256 internal fee;  // VRF fee

    uint256 public randomResult; // store random number

    /**
     * 使用chainlink VRF，构造函数需要继承 VRFConsumerBase 
     * 不同链参数填的不一样
     * 网络: Rinkeby测试网
     * Chainlink VRF Coordinator 地址: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK 代币地址: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (VRF使用费，Rinkeby测试网)
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    function getRandomNum() public returns(bytes32 requestId){
        // ensure LINK token is enough
        require(LINK.balanceOf(address(this)) >= fee, "No enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

}
