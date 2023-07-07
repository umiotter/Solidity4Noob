const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Constant", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployConstantFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const constant = await ethers.deployContract("Constant");

    return { constant, owner, otherAccount };
  }

  describe("Deployment", () => {
    it("run addVarConstnt()", async () => {
      const { constant, owner } = await loadFixture(deployConstantFixture);
      await constant.addVarC();
    });

    it("run addVarImmutable()", async () => {
      const { constant, owner } = await loadFixture(deployConstantFixture);
      await constant.addVarI();
    });

    it("run addVariable()", async () => {
      const { constant, owner } = await loadFixture(deployConstantFixture);
      await constant.addVarV();
    });

    // it("MethodID", async () => {
    //   console.log(
    //     "addVarC()::",
    //     ethers.id("addVarC()").substring(0, 10)
    //   );
    //   console.log(
    //     "addVarI()::",
    //     ethers.id("addVarI()").substring(0, 10)
    //   );
    //   console.log(
    //     "MethodID:addVarV()::",
    //     ethers.id("addVarV()").substring(0, 10)
    //   );
    // });
  });
});
