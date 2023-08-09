const hre = require("hardhat");
const { expect } = require("chai");
describe("Rent And Lend", function () {
  let RentLend, accounts;
  it("", async function () {
    [...accounts] = await hre.ethers.getSigners();
    RentLend = await hre.ethers.deployContract("RentLend", []);
    await RentLend.waitForDeployment();
    console.log("Contract Address: ", RentLend.target);
  });

  it("Addiing Property Details", async function () {
    let txn = await RentLend.connect(accounts[0]).addPropety("2BHk", 100);
    await txn.wait();
    txn = await RentLend.connect(accounts[1]).addPropety("3BHK", 200);
    await txn.wait();
    txn = await RentLend.connect(accounts[2]).addPropety("4BHK", 400);
    await txn.wait();

    let detailsTxn = await RentLend.get_List_of_all_Property();
    console.log("List of Propert Details :", detailsTxn.toString());
  });

  it("Booking should be failed if Price is insufficient", async function () {
    await expect(
      RentLend.BookyourProperty(1, 5, {
        value: 400,
      })
    ).to.reverted;
    await expect(
      RentLend.connect(accounts[10]).BookyourProperty(1, 5, {
        value: 500,
      })
    ).to.emit(RentLend, "bookProperty");
    const detailsTxn = await RentLend.get_list_of_rented_property();
    console.log("List of rented Property: ", detailsTxn.toString());
    const bookingDetails = await RentLend.bookingdetails(accounts[10].address);
    console.log("Bookgin Deataild ", bookingDetails.toString());
  });

  it("only property owner can update ", async function () {
    await expect(
      RentLend.connect(accounts[3]).updatePropertyDetailes(2, "2bhk", 200)
    ).to.reverted;
    const updateTxn = await RentLend.connect(
      accounts[1]
    ).updatePropertyDetailes(2, "2bhk", 200);
    await updateTxn.wait();
    const detailsTxn = await RentLend.PropertyDetailsId(2);
    console.log("Updated Property Details ", detailsTxn.toString());
    const contractBalance = await hre.ethers.provider.getBalance(
      RentLend.target
    );
    console.log("Contract Balance: ", contractBalance.toString());
  });

  it("only customer can cancel their booking", async function () {
    await expect(RentLend.cancelBooking(accounts[8].address)).to.reverted;
    const cancelTxn = await RentLend.cancelBooking(accounts[10].address);
    const bookingDetails = await RentLend.bookingdetails(accounts[10].address);
    console.log("Bookgin Deataild ", bookingDetails.toString());
    const detailsTxn = await RentLend.get_list_of_rented_property();
    console.log("List of rented Property: ", detailsTxn.toString());
  });
});
