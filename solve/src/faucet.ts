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
const RETRY_DELAY = process.env.RETRY_DELAY ? parseInt(process.env.RETRY_DELAY) : 10 * 60 * 1000; // 10分钟重试延迟
const MAX_RETRY_COUNT = 2; // 最大重试2次

// 重试状态管理
let retryCount = 0;
let isRetrying = false;

// 定时调用主函数
async function scheduleFaucetRequests() {
    console.log(`开始定时调用 faucet，间隔: ${SCHEDULE_INTERVAL / (60 * 1000)} 分钟`);
    
    // 立即执行一次
    await executeFaucetRequest();
    
    // 设置定时器
    setInterval(async () => {
        // 如果正在重试中，跳过这次定时调用
        if (!isRetrying) {
            await executeFaucetRequest();
        }
    }, SCHEDULE_INTERVAL);
}

// 执行 faucet 请求，包含重试逻辑
async function executeFaucetRequest() {
    const timestamp = new Date().toLocaleString('zh-CN');
    console.log(`[${timestamp}] 开始执行 faucet 请求...`);
    console.log(`[${timestamp}] 目标地址: ${recipient_address}`);

    // 重置重试状态
    retryCount = 0;
    isRetrying = false;
    
    try {
        const result = await requestSuiFaucet(recipient_address);
        console.log(`[${timestamp}] 领取成功，响应数据:`, JSON.stringify(result, null, 2));
        
        // 获取 SUI 余额，发送到 discord
        console.log(`[${timestamp}] 正在获取当前余额...`);
        const balance = await getSuiBalance(recipient_address);
        console.log(`[${timestamp}] 当前余额: ${balance}`);
        
        
        // 发送成功消息到 Discord，包含余额信息
        await sendDiscordMessage(`✅ Faucet 领取成功！\n时间: ${timestamp}\n地址: ${recipient_address}\n结果: ${JSON.stringify(result)}\n💰 当前余额: ${balance}`);
        
    } catch (err: any) {
        console.error(`[${timestamp}] 请求失败:`, err.message);
        
        // 如果是 429 限流错误，尝试重试
        if (err.response && err.response.status === 429) {
            if (retryCount < MAX_RETRY_COUNT) {
                retryCount++;
                isRetrying = true;
                
                console.log(`[${timestamp}] 检测到限流，第${retryCount}/${MAX_RETRY_COUNT}次重试，${RETRY_DELAY / (60 * 1000)} 分钟后重试...`);
                
                // 发送限流通知到 Discord
                await sendDiscordMessage(`⚠️ Faucet 限流，第${retryCount}/${MAX_RETRY_COUNT}次重试\n时间: ${timestamp}\n地址: ${recipient_address}\n${RETRY_DELAY / (60 * 1000)} 分钟后重试`);
                
                // 延迟重试
                setTimeout(async () => {
                    console.log(`[${new Date().toLocaleString('zh-CN')}] 开始第${retryCount}次重试...`);
                    await executeFaucetRequest();
                }, RETRY_DELAY);
                
            } else {
                console.log(`[${timestamp}] 达到最大重试次数(${MAX_RETRY_COUNT})，停止重试`);
                isRetrying = false;
                
                // 发送重试失败通知到 Discord
                await sendDiscordMessage(`❌ Faucet 重试失败，已达到最大重试次数(${MAX_RETRY_COUNT})\n时间: ${timestamp}\n地址: ${recipient_address}\n请检查网络或稍后手动重试`);
            }
        } else {
            // 其他错误，重置重试状态
            retryCount = 0;
            isRetrying = false;
            
            // 根据错误类型发送不同的通知
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
    console.log(`- 调用间隔: ${SCHEDULE_INTERVAL / (60 * 1000)} 分钟`);
    console.log(`- 重试延迟: ${RETRY_DELAY / (60 * 1000)} 分钟`);

    //初始sui余额
    const timestamp = new Date().toLocaleString('zh-CN');
    console.log(`[${timestamp}] 正在获取初始余额...`);
    const balance = await getSuiBalance(recipient_address);
    console.log(`[${timestamp}] 初始余额: ${balance}`);
    
    // 启动定时调用
    await scheduleFaucetRequests();
    
    // 保持程序运行
    console.log("程序已启动，按 Ctrl+C 停止...");
}

// 如果直接运行此文件，则执行 main 函数
if (require.main === module) {
    main().catch(console.error);
}













