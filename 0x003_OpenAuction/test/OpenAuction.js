const zeroAddress = "0x0000000000000000000000000000000000000000";

const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  loadFixture,
  helpers,
  time,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("OpenAuction Contract", () => {
  async function deployOpenAutcitonFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const acution = await ethers.deployContract("OpenAuction", [120, owner]);

    return { acution, owner, addr1, addr2 };
  }

  // Test case
  describe("Deployment", () => {
    it("should set the right beneficiary address.", async () => {
      const { acution, owner, addr1, addr2 } = await loadFixture(
        deployOpenAutcitonFixture
      );

      expect(await acution.beneficiary()).to.equal(owner.address);
    });

    it("should set the right auction end time.", async () => {
      const { acution, owner, addr1, addr2 } = await loadFixture(
        deployOpenAutcitonFixture
      );
      const currTime = await time.latest();
      expect(await acution.auctionEndTime()).to.above(currTime);
    });
  });

  describe("Bid", () => {
    describe("Behavious", () => {
      it("should store a highest bid price.", async () => {
        const { acution, owner, addr1, addr2 } = await loadFixture(
          deployOpenAutcitonFixture
        );

        await expect(acution.bid({ value: ethers.parseEther("1") }))
          .to.emit(acution, "HighestBidIncreased")
          .withArgs(owner.address, ethers.parseEther("1"));
        await expect(
          acution.connect(addr1).bid({ value: ethers.parseEther("2") })
        )
          .to.emit(acution, "HighestBidIncreased")
          .withArgs(addr1.address, ethers.parseEther("2"));
      });

      it("should able to withdraw after price are exceeded.", async () => {
        const { acution, owner, addr1, addr2 } = await loadFixture(
          deployOpenAutcitonFixture
        );

        await acution.bid({ value: ethers.parseEther("1") });
        await acution.connect(addr1).bid({ value: ethers.parseEther("2") });

        await expect(acution.withdraw()).to.emit(acution, "WithdrawSuccess");
      });
    });

    describe("Validations", () => {
      it("should revert if withdraw amount is zero.", async () => {
        const { acution, owner, addr1, addr2 } = await loadFixture(
          deployOpenAutcitonFixture
        );

        await expect(acution.withdraw()).to.be.reverted;
      });

      it("should revert when call acutionEnd before acution ended.", async () => {
        const { acution, owner, addr1, addr2 } = await loadFixture(
          deployOpenAutcitonFixture
        );

        await expect(acution.auctionEnd()).to.be.revertedWithCustomError(
          acution,
          "AcutionNotYetEnded"
        );
      });

      it("should revert when call acutionEnd after acution ended.", async () => {
        const { acution, owner, addr1, addr2 } = await loadFixture(
          deployOpenAutcitonFixture
        );

        await time.increase(3600);
        await expect(acution.auctionEnd()).to.emit(acution, "AcutionEnded");

        await expect(acution.auctionEnd()).to.be.revertedWithCustomError(
          acution,
          "AcutionAlreadyEnded"
        );
      });
    });
  });
});
