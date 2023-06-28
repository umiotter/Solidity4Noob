const zeroAddress = "0x0000000000000000000000000000000000000000";

const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  loadFixture,
  helpers,
  time,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("MultiCall", function () {
  async function deployUmiERC20Fixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const umiToken = await ethers.deployContract("UmiToken");
    const multiCall = await ethers.deployContract("MultiCall");

    return { umiToken, multiCall, owner, addr1, addr2 };
  }

  describe("Validation", function () {
    it("should mint 50 UmiToken to addr1 and 100 UmiToken to addr2.", async () => {
      const { umiToken, multiCall, owner, addr1, addr2 } = await loadFixture(
        deployUmiERC20Fixture
      );

      const umiTokenAddr = umiToken.target;
      const calldata = [
        [
          umiTokenAddr,
          false,
          "0x40c10f1900000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c80000000000000000000000000000000000000000000000000000000000000032",
        ],
        [
          umiTokenAddr,
          false,
          "0x40c10f1900000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c80000000000000000000000000000000000000000000000000000000000000064",
        ],
      ];
      await multiCall.multicall(calldata);
      expect(await umiToken.balanceOf(addr1.address)).to.equal(50);
      expect(await umiToken.balanceOf(addr2.address)).to.equal(100);
    });
  });
});
