import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Staking", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployStakingFixture() {
   

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("jonStaking");
    const token = await Token.deploy(owner.address);
    
    await token.deployed()
        // deploy the staking
    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.deploy(token.address);
    await staking.deployed()

    const tokenAddress = token.address;
    const stakingAddress = staking.address;;
    const tokenSupply = await ethers.utils.parseEther("100000")

    return {token, staking, tokenAddress, stakingAddress, owner, otherAccount, tokenSupply}
  }

  describe("Deployment", function () {
    it("Should check the contract balance is zero", async function () {
            const {token, staking} = await loadFixture(deployStakingFixture);

            expect(await token.balanceOf(staking.address)).to.equal(0)
        })
        it("Should check the deployer balance is 100000e18", async function () {
            const {token, owner, tokenSupply} = await loadFixture(deployStakingFixture);

            expect(await token.balanceOf(owner.address)).to.equal(tokenSupply);
        })

       describe("Send Token to a contract and other account", async function (){
        it("Should send token to a contract", async function () {
            const {token, owner, staking} = await loadFixture(deployStakingFixture);
            const amountToSend = await ethers.utils.parseEther("50000")

            await token.transfer(staking.address, amountToSend)
            expect(await token.balanceOf(staking.address)).to.equal(amountToSend);
            expect(await token.balanceOf(owner.address)).to.equal(amountToSend);
        })

    })
  });

});
