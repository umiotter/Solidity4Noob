const zeroAddress = "0x0000000000000000000000000000000000000000";

const { expect } = require("chai");
const hre = require("hardhat");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Ballot Contract", () => {
  async function deployBallotFixture() {
    const candidateList = [
      "0x4170706c65000000000000000000000000000000000000000000000000000000",
      "0x4d6963726f736f66740000000000000000000000000000000000000000000000",
      "0x476f6f676c650000000000000000000000000000000000000000000000000000",
    ];

    const ballot = await ethers.deployContract("Ballot", [candidateList]);
    const [owner, addr1, addr2] = await ethers.getSigners();

    return { ballot, owner, addr1, addr2, candidateList };
  }

  // Test case
  describe("in Deployment", () => {
    it("should have legal chairman.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      expect(await ballot.chairperson()).to.equal(owner.address);
    });

    it("should successfuly load candidate list.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      for (let i = 0; i < candidateList.length; i++) {
        const result = await ballot.proposals(i);
        expect(result.name).to.equal(candidateList[i]);
        expect(result.voteCount).to.equal(0);
      }
    });
  });

  describe("in Runtime", () => {
    it("should esmpower a address the right to vote by chairman.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await ballot.esmpowerToVote(addr1);
      const result = await ballot.voters(addr1);

      expect(result.weight).to.equal(1);
    });

    it("should not esmpower a address the right to vote by non-chairman.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await expect(ballot.connect(addr1).esmpowerToVote(addr2)).to.be.reverted;
    });

    it("should successfuly vote a proposal.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await ballot.esmpowerToVote(addr1);
      await ballot.connect(addr1).vote(0);
      const result = await ballot.proposals(0);

      expect(result.voteCount).to.equal(1);
    });

    it("should not allow a illegal address to vote a proposal.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await expect(ballot.connect(addr1).vote(0)).to.be.reverted;
    });

    it("should allow a legal address to set a delegatee for voting.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await ballot.esmpowerToVote(addr1);
      await ballot.esmpowerToVote(addr2);
      await ballot.connect(addr1).setDelegatee(addr2);
      await ballot.connect(addr2).vote(0);
      const result = await ballot.proposals(0);

      expect(result.voteCount).to.equal(2);
    });

    it("should not allow a illegal address to set a delegatee for voting.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await expect(ballot.connect(addr1).setDelegatee(addr2)).to.be.reverted;
    });

    it("should not allow a address to set a illegal delegatee for voting.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await ballot.esmpowerToVote(addr1);

      await expect(ballot.connect(addr1).setDelegatee(addr2)).to.be.reverted;
    });

    it("should output current winning proposal's number.", async () => {
      const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
        deployBallotFixture
      );

      await ballot.esmpowerToVote(addr1);
      await ballot.vote(0);
      await ballot.connect(addr1).vote(0);

      const result = await ballot.currentWinningProposal();
      expect(result[0]).to.equal(BigInt(0));
    });

    it("should output two winning proposal's number when there are proposals have same votes amount.", async () => {
        const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
          deployBallotFixture
        );
  
        await ballot.esmpowerToVote(addr1);
        await ballot.vote(0);
        await ballot.connect(addr1).vote(1);
  
        const result = await ballot.currentWinningProposal();
        expect(result[0]).to.equal(BigInt(0));
        expect(result[1]).to.equal(BigInt(1));
      });

    it("should output winning proposal's name.", async () => {
        const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
          deployBallotFixture
        );
  
        await ballot.esmpowerToVote(addr1);
        await ballot.vote(0);
        await ballot.connect(addr1).vote(0);
  
        const result = await ballot.winnerName();
        expect(result[0]).to.equal(candidateList[0]);
      });

      it("should output two winning proposal's names when there are proposals have same votes amount.", async () => {
        const { ballot, owner, addr1, addr2, candidateList } = await loadFixture(
          deployBallotFixture
        );
  
        await ballot.esmpowerToVote(addr1);
        await ballot.vote(0);
        await ballot.connect(addr1).vote(1);
  
        const result = await ballot.winnerName();
        expect(result[0]).to.equal(candidateList[0]);
        expect(result[1]).to.equal(candidateList[1]);
      });
  });
});
