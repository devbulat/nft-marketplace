import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";

task("mint", "Mint")
  .addParam("contract", "Contract address")
  .addParam("tokenUri", "Token Uri")
  .setAction(async (args, hre) => {
    const { contract, tokenUri } = args;
    const Contract = await hre.ethers.getContractFactory("NftMarketplace");
    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];

    const NftMarketplace = await new hre.ethers.Contract(
      contract,
      Contract.interface,
      signer
    );

    await NftMarketplace.createItem(tokenUri).then(() => {
      console.log(`Token with token URI ${tokenUri} is created!`);
    });
  });

export default {};