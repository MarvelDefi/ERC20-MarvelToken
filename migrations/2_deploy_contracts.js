const Token = artifacts.require("Token");
const ICO = artifacts.require("ICO");

module.exports = async function (deployer) {
  const totalSupply = 1500000; //1M

  //Token
  await deployer.deploy(
    Token,
    'MARVEL NFT Token', //name
    'MARVEL',          //sticker
    totalSupply
  );
  const token = await Token.deployed();

  //ICO
  await deployer.deploy(
    ICO,
    token.address,
    592200,                         // duration (592200s = 1 week)
    web3.utils.toWei('1'),          // price of 1 token in BUSD (wei) (= 0.002 BUSD. 0.002 * 1M = 20,00 BUSD ~= 20,000 USD)
    totalSupply,                    //_availableTokens for the ICO. can be less than maxTotalSupply
    1,                              //_minPurchase (in BUSD)
    500000                            //_maxPurchase (in BUSD)
  );
  const ico = await ICO.deployed();
  await token.updateAdmin(ico.address);
  await ico.start();
};