async function main() {
  console.log(`Preparing deployment...\n`);

  // Fetch contract to deploy
  const Minions20 = await ethers.getContractFactory("Minions20");

  // Deploy contract
  const minions20 = await Minions20.deploy();
  await minions20.deployed();
  console.log(`Contract deployed to address: ${minions20.address}`);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
