const { ethers } = require("ethers");
const {abi, contractAddress} = require('./contractData.js');

const urlTestNet = 'https://alfajores-forno.celo-testnet.org';

const provider = new ethers.providers.StaticJsonRpcProvider(urlTestNet);

// const publicKey = "0xFA5551300D6C50730880EbC1B0347e4Bc1e8c8eC";

// const privateKey = "9a5a3757fed4424cc56b6145f6cb603cb875618c00b744e99ffbe702cf4edd42";

const publicKey = "0xE4783a07b97c7adC3320F393a1D386CB7A4180ec";

const privateKey = "e142ac12694913f478b39df66e10a7cf89dbab4a67ebd1efe94ba3f3b53c5bb3";

const signer = new ethers.Wallet(privateKey, provider);

const contract = new ethers.Contract(contractAddress, abi, signer);

data="0xE4783a07b97c7adC3320F393a1D386CB7A4180ec";
  
console.log("la address a inscribir es:"+data);
console.log("Estamos registrando su address en la whitelist de la blockchain...");
write_data();
async function write_data(){
    try{
        await contract.whitelistAddress(provider.toChecksumAddress(data)).then((receipt) => {
            hashTransaction = "https://alfajores-blockscout.celo-testnet.org/tx/"+ receipt.hash;
            console.log("Puede consultar la transacción en:" + hashTransaction);
        });
    }
    catch(err){
        console.log("**********************ERROR****************");
        console.log(err);
    }
}






