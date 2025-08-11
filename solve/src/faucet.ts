import { getFaucetHost, requestSuiFromFaucetV2 } from '@mysten/sui/faucet';


import dotenv from 'dotenv';
dotenv.config();


const recipient_address = process.env.ADDRESS || '';
const network = (process.env.NETWORK as 'testnet' | 'devnet' | 'localnet') || 'testnet';


//v1
// //没办法正常跑, aws上也试过了, 不知道哪儿限流了
// async function getTestSui() {
    
//     const faucetUrl = getFaucetHost(network); //'https://faucet.testnet.sui.io/v2/gas'; // Testnet faucet 地址
  
//     //https://faucet.testnet.sui.io
//     console.log(`${network} faucetUrl: ${faucetUrl}`);
  
//     const response = await requestSuiFromFaucetV2({
//       host: faucetUrl,
//       recipient: address,
//     });
//     console.log(`recipient: ${address}`);
//     console.log('response', response);
  
//   //FaucetRateLimitError: Too many requests from this client have been sent to the faucet. Please retry later
  
//   }
  
  
//   getTestSui();






//POST https://faucet.testnet.sui.io/v2/gas
// Content-Type: application/json

// {
//   "FixedAmountRequest": {
//     "recipient": "你的钱包地址"
//   }
// }


// 假设你用 axios 发送 faucet 请求
import axios from "axios";

// 记录上次请求时间
let lastRequestTime: number | null = null;
// 限流间隔（单位：毫秒），比如 1 小时
const RATE_LIMIT_INTERVAL = 60 * 60 * 1000; // 1 小时

async function requestSuiFaucet(address: string) {

    console.log(`recipient: ${address}`);

    const now = Date.now();
    if (lastRequestTime && now - lastRequestTime < RATE_LIMIT_INTERVAL) {
        throw new Error("请求太频繁，请稍后再试！");
    }

    try {
        //charome里直接贴url后，显示 Too Many Requests! Wait for 1s
        const resp = await axios.post("https://faucet.testnet.sui.io/v2/gas", {
        FixedAmountRequest: { recipient: address }
        });
        lastRequestTime = now;
        return resp.data;
    } catch (e: any) {
        if (e.response && e.response.status === 429) {
            throw new Error("官方 faucet 限流，请稍后再试！");
        }
        throw e;
    }
}

// 用法示例
(async () => {
  try {
    const result = await requestSuiFaucet(recipient_address);
    console.log("领取成功：", result);
  } catch (err: any) {
    console.error(err.message);
  }
})();








