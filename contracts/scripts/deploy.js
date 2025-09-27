const hre = require("hardhat");

async function main() {
  const [deployer, operator, user] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);

  // 1) Mock LST
  const LST = await hre.ethers.getContractFactory("MockLST");
  const lst = await LST.deploy();
  await lst.waitForDeployment();
  console.log("MockLST:", await lst.getAddress());

  // 2) Vault
  const Vault = await hre.ethers.getContractFactory("RestakeVault");
  const vault = await Vault.deploy(await lst.getAddress());
  await vault.waitForDeployment();
  console.log("RestakeVault (rstLST):", await vault.getAddress());

  // 3) Operator yetkisi ver, biraz mLST ver
  await (await vault.setOperator(operator.address, true)).wait();
  await (await lst.mint(operator.address, hre.ethers.parseEther("10000"))).wait();
  await (await lst.mint(user.address, hre.ethers.parseEther("10000"))).wait();

  // 4) User: approve + deposit
  await (await lst.connect(user).approve(await vault.getAddress(), hre.ethers.MaxUint256)).wait();
  await (await vault.connect(user).deposit(hre.ethers.parseEther("1000"), user.address)).wait();
  console.log("User deposited 1000 mLST → got rstLST shares");

  // 5) Operator donate → getiri simülasyonu
  await (await lst.connect(operator).approve(await vault.getAddress(), hre.ethers.MaxUint256)).wait();
  await (await vault.connect(operator).donate(hre.ethers.parseEther("100"))).wait();
  console.log("Operator donated 100 mLST");

  // 6) Fiyat kontrol
  const pps = await vault.pricePerShare();
  console.log("pricePerShare (assets per 1 share):", hre.ethers.formatEther(pps));
}

main().catch((e) => { console.error(e); process.exitCode = 1; });
