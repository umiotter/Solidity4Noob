const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CalldataAndMemory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployCalldataAndMemoryFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const calldataAndMemory = await ethers.deployContract("CalldataAndMemory");

    return { calldataAndMemory, owner, otherAccount };
  }

  describe("Deployment", () => {
    console.log(
      "MethodID:",
      ethers.id("writeByCalldata(Person)").substring(0, 10) >
        ethers.id("writeByMemory(Person)").substring(0, 10)
    );

    it("run writeByCalldata()", async () => {
      const { calldataAndMemory, owner, otherAccount } = await loadFixture(
        deployCalldataAndMemoryFixture
      );
      await calldataAndMemory.writeByCalldata([18, "suzumiya", "fun"]);
    });

    it("run writeByMemory()", async () => {
      const { calldataAndMemory, owner, otherAccount } = await loadFixture(
        deployCalldataAndMemoryFixture
      );
      await calldataAndMemory.writeByMemory([18, "suzumiya", "fun"]);
    });
  });
});
