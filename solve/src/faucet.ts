import { getFaucetHost, requestSuiFromFaucetV2 } from '@mysten/sui/faucet';

const address = '';

//基本上没办法正常跑


async function getTestSui() {
  const faucetUrl = getFaucetHost('testnet'); //'https://faucet.testnet.sui.io/v2/gas'; // Testnet faucet 地址

  //https://faucet.testnet.sui.io
  console.log('faucetUrl', faucetUrl);

  const response = await requestSuiFromFaucetV2({
    host: faucetUrl,
    recipient: address,
  });
  console.log(response);

//FaucetRateLimitError: Too many requests from this client have been sent to the faucet. Please retry later

}

getTestSui();
