const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("SwapComparision", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploySwapComparisonFixture() {
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await ethers.getSigners();
  
      const swapVarsTest = await ethers.deployContract("SwapVarsTest");
  
      return { swapVarsTest, owner, otherAccount };
    }
  
    describe("Deployment", () => {
      it("run testSwap()", async () => {
        const { swapVarsTest, owner } = await loadFixture(deploySwapComparisonFixture);
        await swapVarsTest.setUp();
        await swapVarsTest.testSwap();
      });
  
      it("run testDesSwap()", async () => {
        const { swapVarsTest, owner } = await loadFixture(deploySwapComparisonFixture);
        await swapVarsTest.setUp();
        await swapVarsTest.testDesSwap();
      });
  
      it("run testBitOperationSwap()", async () => {
        const { swapVarsTest, owner } = await loadFixture(deploySwapComparisonFixture);
        await swapVarsTest.setUp();
        await swapVarsTest.testBitOperationSwap();
      });
  
    });
  });
  