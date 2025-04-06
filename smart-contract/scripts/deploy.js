async function main() {
    const Matcher = await ethers.getContractFactory("Matcher");
    const matcher = await Matcher.deploy();
  
    console.log("✅ Matcher object:", matcher); // 추가
    console.log("✅ Matcher deployed at:", matcher.target);
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  