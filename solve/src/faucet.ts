import { getFaucetHost, requestSuiFromFaucetV2 } from '@mysten/sui/faucet';


import dotenv from 'dotenv';
dotenv.config();


const address = process.env.ADDRESS || '';
const network = (process.env.NETWORK as 'testnet' | 'devnet' | 'localnet') || 'testnet';

//基本上没办法正常跑


async function getTestSui() {
    
  const faucetUrl = getFaucetHost(network); //'https://faucet.testnet.sui.io/v2/gas'; // Testnet faucet 地址

  //https://faucet.testnet.sui.io
  console.log(`${network} faucetUrl: ${faucetUrl}`);

  const response = await requestSuiFromFaucetV2({
    host: faucetUrl,
    recipient: address,
  });
  console.log(`recipient: ${address}`);
  console.log('response', response);

//FaucetRateLimitError: Too many requests from this client have been sent to the faucet. Please retry later

}

getTestSui();
