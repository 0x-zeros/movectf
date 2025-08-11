import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN!;
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID!;
const DISCORD_WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL!;


//Telegram 未测过

// 生成一个随机数
function generateRandomNumber() {
    return Math.floor(Math.random() * 1000);
}

// 发送到 Telegram
async function sendTelegramMessage(message: string) {
    try {
        const url = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`;
        await axios.post(url, {
            chat_id: TELEGRAM_CHAT_ID,
            text: message
        }, {
            timeout: 5000
        });
        console.log("Telegram 发送成功");
    } catch (err: any) {
        console.error("Telegram Error:", err.response?.data || err.message);
    }
}

// 发送到 Discord Webhook
async function sendDiscordMessage(message: string) {
    try {
        await axios.post(DISCORD_WEBHOOK_URL, {
            content: message
        }, {
            timeout: 5000
        });
        console.log("Discord message:", message);
    } catch (err: any) {
        console.error("Discord Error:", err.response?.data || err.message);
    }
}

async function main() {
    const randomNum = generateRandomNumber();
    const message = `随机数: ${randomNum}`;
    console.log("发送消息:", message);

    await Promise.all([
        // sendTelegramMessage(message),
        sendDiscordMessage(message),
    ]);

    console.log("发送完成！");
}

main().catch(console.error);