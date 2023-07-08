const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("BitmapAndBoolArray", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployBitmapAndBoolArrayFixture() {
      // Contracts are deployed using the first signer/account by default
      const [owner, otherAccount] = await ethers.getSigners();
  
      const bitmapAndBoolArray = await ethers.deployContract("BitmapAndBoolArray");
  
      return { bitmapAndBoolArray, owner, otherAccount };
    }
  
    describe("Deployment", () => {
  
      it("run setDataWithBoolArray()", async () => {
        const { bitmapAndBoolArray, owner, otherAccount } = await loadFixture(
            deployBitmapAndBoolArrayFixture
        );

        let inputData = [false,false,false,true,false,false,false,false];
        await bitmapAndBoolArray.setDataWithBoolArray(inputData);

        // check the result 
        for(let i=0; i<8; i++){
            const res = await bitmapAndBoolArray.readWithBoolArray(i);
            expect(res).to.equal(inputData[i]);
        }
      });
  
      it("run setDataWithBitmap()", async () => {
        const { bitmapAndBoolArray, owner, otherAccount } = await loadFixture(
            deployBitmapAndBoolArrayFixture
        );
        let inputData = 0b1000;
        let inputDataBoolArray = [false,false,false,true,false,false,false,false]
        await bitmapAndBoolArray.setDataWithBitmap(inputData);

        // check the result 
        for(let i=0; i<8; i++){
            const res = await bitmapAndBoolArray.readWithBitmap(i);
            expect(res).to.equal(inputDataBoolArray[i]);
        }
      });

    });
  });
  