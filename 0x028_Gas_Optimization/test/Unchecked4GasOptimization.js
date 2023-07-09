const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("Unchecked", function () {

    async function deployUncheckedFixture() {
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await ethers.getSigners();
  
      const unchecked = await ethers.deployContract("Unchecked");
  
      return { unchecked, owner, otherAccount };
    }
  
    describe("Deployment", () => {
      it("run withoutUnckecked()", async () => {
        const { unchecked, owner } = await loadFixture(deployUncheckedFixture);
        await unchecked.withoutUnckecked(1000);
      });
  
      it("run withUnckecked()", async () => {
        const { unchecked, owner } = await loadFixture(deployUncheckedFixture);
        await unchecked.withUnckecked(1000);
      });
    });
  });
  