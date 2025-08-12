import axios from "axios";
import dotenv from 'dotenv';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';

dotenv.config();

// 在文件开头添加 Sui 客户端导入




const recipient_address = process.env.ADDRESS || '';
const network = (process.env.NETWORK as 'testnet' | 'devnet' | 'localnet') || 'testnet';

const DISCORD_WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL!;

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

// 创建 Sui 客户端
const suiClient = new SuiClient({ url: getFullnodeUrl(network) });

// 获取 SUI 余额的函数
async function getSuiBalance(address: string): Promise<string> {
    try {
        const balance = await suiClient.getBalance({
            owner: address,
            coinType: '0x2::sui::SUI'
        });
        
        // 转换为可读格式 (SUI 有9位小数)
        const balanceInSui = (BigInt(balance.totalBalance) / BigInt(1000000000)).toString();
        const balanceInMist = balance.totalBalance;
        
        return `${balanceInSui} SUI (${balanceInMist} MIST)`;
    } catch (error: any) {
        console.error('获取余额失败:', error.message);
        return '获取失败';
    }
}


async function requestSuiFaucet(address: string) {

    // console.log(`recipient: ${address}`);

    try {
        //charome里直接贴url后，显示 Too Many Requests! Wait for 1s
        const resp = await axios.post("https://faucet.testnet.sui.io/v2/gas", {
        FixedAmountRequest: { recipient: address }
        });
        return resp.data;
    } catch (e: any) {
        // if (e.response && e.response.status === 429) {
        //     throw new Error("官方 faucet 限流，请稍后再试！");
        // }
        throw e;
    }
}

// 发送到 Discord Webhook
async function sendDiscordMessage(message: string) {
    if (!DISCORD_WEBHOOK_URL) {
        // console.warn("未设置 DISCORD_WEBHOOK_URL，将不会发送 Discord 通知");
        return;
    }

    //message 后面添加分割线
    message += "\n--------------------------------\n\n\n";
    
    console.log("send discord message:", message);
    try {
        await axios.post(DISCORD_WEBHOOK_URL, {
            content: message
        }, {
            timeout: 5000
        });
        
    } catch (err: any) {
        console.error("Discord Error:", err.response?.data || err.message);
    }
}

// 定时调用配置
const SCHEDULE_INTERVAL = process.env.SCHEDULE_INTERVAL ? parseInt(process.env.SCHEDULE_INTERVAL) : 60 * 60 * 1000; // 默认1小时
const RETRY_DELAY = 60 * 1000; // 1分钟重试延迟

// 封装间隔时间函数
//isSuccess: wait之前的faucet是否成功; true 成功，false 失败
//waitTimePrev: 上一次等待时间
// 修改 waitInterval 函数，返回实际等待时间
async function waitInterval(isSuccess: boolean, waitTimePrev: number): Promise<number> {
    let delay: number;
    let intervalName: string;

    //如果上一次成功，或者上一次等待时间等于1分钟(重试延迟)，则等待1小时
    let isLongInterval = isSuccess || waitTimePrev == RETRY_DELAY;
    
    if (isLongInterval) {
        // 1小时间隔 + 随机扰动
        //等待时间会是：1小时 + (1秒到6分钟)的随机时间，可以有效避免被检测到固定的请求模式。
        const randomDelay = Math.floor(Math.random() * (SCHEDULE_INTERVAL / 10)) + 1000;
        delay = SCHEDULE_INTERVAL + randomDelay;
        intervalName = `${SCHEDULE_INTERVAL / (60 * 1000)} 分钟 + ${randomDelay / 1000} 秒随机扰动`;
    } else {
        // 1分钟间隔
        delay = RETRY_DELAY;
        intervalName = `${RETRY_DELAY / 1000} 秒`;
    }
    
    const timestamp = new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' });
    console.log(`[${timestamp}] 等待 ${intervalName} 后执行...`);
    await new Promise(resolve => setTimeout(resolve, delay));
    
    return delay; // 返回实际等待时间
}

// 主循环函数，替换原来的定时调用
async function mainLoop() {
    console.log(`开始主循环，成功间隔: ${SCHEDULE_INTERVAL / (60 * 1000)} 分钟，失败间隔: ${RETRY_DELAY / 1000} 秒`);
    
    let waitTimePrev = SCHEDULE_INTERVAL;//上一次等待时间
    while (true) {
        const timestamp = new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' });
        console.log(`[${timestamp}] 开始执行 faucet 请求...`);
        console.log(`[${timestamp}] 目标地址: ${recipient_address}`);

        try {
            const result = await requestSuiFaucet(recipient_address);
            console.log(`[${timestamp}] 领取成功，响应数据:`, JSON.stringify(result, null, 2));
            
            // 获取 SUI 余额，发送到 discord
            //等待一分钟，等json rpc同步balance
            await new Promise(resolve => setTimeout(resolve, 60 * 1000));
            console.log(`[${timestamp}] 正在获取当前余额...`);
            const balance = await getSuiBalance(recipient_address);
            console.log(`[${timestamp}] 当前余额: ${balance}`);
            
            // 发送成功消息到 Discord，包含余额信息
            await sendDiscordMessage(`✅ Faucet 领取成功！\n时间: ${timestamp}\n地址: ${recipient_address}\n结果: ${JSON.stringify(result)}\n💰 当前余额: ${balance}`);
            
            // 成功：等待1小时 + 随机扰动，并更新 waitTimePrev
            waitTimePrev = await waitInterval(true, waitTimePrev);
            
        } catch (err: any) {
            console.error(`[${timestamp}] 请求失败:`, err.message);
            
            // 发送失败通知
            let errorMessage = `❌ Faucet 请求失败\n时间: ${timestamp}\n地址: ${recipient_address}\n错误: ${err.message}`;
            
            if (err.response) {
                // HTTP 错误
                errorMessage += `\n状态码: ${err.response.status}`;
                if (err.response.data) {
                    errorMessage += `\n响应数据: ${JSON.stringify(err.response.data)}`;
                }
            } else if (err.request) {
                // 网络错误
                errorMessage += `\n网络错误: 无法连接到服务器`;
            } else {
                // 其他错误
                errorMessage += `\n错误类型: ${err.name || 'Unknown Error'}`;
            }
            
            await sendDiscordMessage(errorMessage);
            
            // 失败：等待1分钟，并更新 waitTimePrev
            waitTimePrev = await waitInterval(false, waitTimePrev);
        }
    }
}

async function main() {
    if (!recipient_address) {
        console.error("请设置 ADDRESS 环境变量");
        process.exit(1);
    }
    
    if (!DISCORD_WEBHOOK_URL) {
        console.warn("未设置 DISCORD_WEBHOOK_URL，将不会发送 Discord 通知");
    }
    
    console.log(`配置信息:`);
    console.log(`- 网络: ${network}`);
    console.log(`- 地址: ${recipient_address}`);
    console.log(`- 成功间隔: ${SCHEDULE_INTERVAL / (60 * 1000)} 分钟`);
    console.log(`- 失败重试间隔: ${RETRY_DELAY / 1000} 秒`);

    //初始sui余额
    const timestamp = new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' });
    console.log(`[${timestamp}] 正在获取初始余额...`);
    const balance = await getSuiBalance(recipient_address);
    console.log(`[${timestamp}] 初始余额: ${balance}`);
    
    // 启动主循环
    await mainLoop();
    
    // 保持程序运行
    console.log("程序已启动，按 Ctrl+C 停止...");
}

// 如果直接运行此文件，则执行 main 函数
if (require.main === module) {
    main().catch(console.error);
}













