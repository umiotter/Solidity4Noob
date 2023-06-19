const zeroAddress = "0x0000000000000000000000000000000000000000";

const { expect } = require("chai");
const hre = require("hardhat");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Voting contract", () => {
  async function deployVotingFixture() {
    const candidateList = [
      "0x4170706c65000000000000000000000000000000000000000000000000000000",
      "0x4d6963726f736f66740000000000000000000000000000000000000000000000",
      "0x476f6f676c650000000000000000000000000000000000000000000000000000",
    ];

    const voting = await ethers.deployContract("Voting", [candidateList]);
    const [owner, addr1, addr2] = await ethers.getSigners();

    return { voting, owner, addr1, addr2, candidateList };
  }

  // Test case
  describe("Candidate List be the same.", () => {
    it("Should successfuly ", async () => {
      const { voting, owner, addr1, addr2, candidateList } = await loadFixture(
        deployVotingFixture
      );

      // const result = await voting.candidateList();
      for (let i = 0; i < candidateList.length; i++) {
        expect(await voting.candidateList(i)).to.equal(candidateList[i]);
      }
    });
  });
});
