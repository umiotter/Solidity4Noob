const { expect } = require("chai");
const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("UmiotterToken", function () {
  async function deployUmiotterTokenFixture() {
    const tokenName = "Umiotter";
    const tokenSymbol = "UOT";

    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2] = await ethers.getSigners();

    const umiottertoken = ether.ethers.deployContract("UmiotterToken",{tokenName, tokenSymbol});

    return { umiottertoken, tokenName, tokenSymbol, owner, addr1, addr2 };
  }
});
