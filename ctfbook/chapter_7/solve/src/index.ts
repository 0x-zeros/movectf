import { Transaction } from '@mysten/sui/transactions';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';

import axios from 'axios';
import * as fs from 'fs';
import * as os from 'os';

const env = 'devnet';
const suiRpcUrl = getFullnodeUrl(env);

//testnet
// const heroId = '0x6b78a8546544534f9b008f23b83ccc289db036d090b48551a3ad47bc73f0a6bd';// heroId
// const userTokenAmountId = '0xbc7227801697b492f14b1414d96cb7df70c267ad982811a6eedb8c8a1e2c9fcb';// userTokenAmountId
// const PACKAGE_ID = '0xf56f48f5104463bf4f60eb8daaaafb22de896f36f5ac11f49954de8c7ecd0a1c'; // PACKAGE_ID

//devnet
const heroId = '0xbf4e702c9ae6f783fddc83bd545e7514f25b6eff4809130c46d41f51b674c785';// heroId
const userTokenAmountId = '0xd03f5355e3d96e50ca2b68bdc21902b14ff4d8a829f05b4f866082c05a1e81a7';// userTokenAmountId
const PACKAGE_ID = '0x84ee4aaafac1983af6340711bf4bf679b3875ce0aeeb0e1913dc3ee1479e12fd'; // PACKAGE_ID

//devnet get_flag tx digest: HX7Y6z2GaDJDFuyXgsydTfQV8i9SSg5TA1v29kAkiUk6

function get_keypair_from_keystore(){
    const keystorePath = os.homedir() + '/.sui/sui_config/sui.keystore';
    // console.log('filepath: ', keystorePath);

    // 读取 keystore 文件
    const keystoreData = JSON.parse(fs.readFileSync(keystorePath, 'utf-8'));

    // 选择一个 key（通常第一个）
    const base64PrivateKey = keystoreData[0]; // keystoreData 为 base64 字符串数组

    //Wrong secretKey size. Expected 32 bytes, got 33.
    //33-byte flag || privkey
    //https://docs.sui.io/references/cli/keytool#generate-a-new-key-pair-and-store-it-in-a-file

    // 从 base64 解码并跳过第一个字节（密钥类型标识符）
    const privateKeyBytes = Buffer.from(base64PrivateKey, 'base64').subarray(1);

    // 从 32 字节私钥创建 keypair
    const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);

    return keypair;
}

async function get_experience() {
    try {
        const response = await axios.post(suiRpcUrl,{jsonrpc: '2.0',id: 1, method: 'sui_getObject',params: [heroId,{showType: true,showOwner: true,showDepth: true,showContent: true,showDisplay: true,},],},{headers: {'Content-Type': 'application/json',},});
        const fields = response.data.result?.data?.content?.fields;
        if (fields) {console.log('Experience:', fields.experience);console.log('Level', fields.level)} else {console.log('No fields found in the object.');}
        return fields.experience 
    } catch (error: any) {
        console.error('Error fetching object data:', error.message);
    }
}

async function get_transaction_events(digest: string) {
    try {
        const response = await axios.post(suiRpcUrl, {
            jsonrpc: '2.0',
            id: 1,
            method: 'sui_getTransactionBlock',
            params: [
                digest, 
                {showInput: false,showRawInput: false,showEffects: false,showEvents: true, showObjectChanges: false,showBalanceChanges: false}
            ]
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        const events = response.data.result?.events;
        if (events && events.length > 0) {
            console.log('交易触发的事件列表:');
            let amount = null;
            for (const event of events){
                if (event.parsedJson && 'amount' in event.parsedJson) {
                    amount = parseInt(event.parsedJson.amount, 10); 
                    console.log('Amount:', amount);
                    break;
                }else{
                    console.log('事件内容:', event.parsedJson);
                }
            }
            return amount;
        } else {
            console.log('该交易没有触发任何事件。');
            return 0;
        }

    } catch (error: any) {
        console.error('获取交易事件失败:', error.message);
        return 0;
    }
}

async function get_newly_created_object(digest: string) {
    try {
        const response = await axios.post(suiRpcUrl, {
            jsonrpc: '2.0',
            id: 1,
            method: 'sui_getTransactionBlock',
            params: [
                digest,
                {
                    showEffects: true,
                    showObjectChanges: true
                }
            ]
        }, {
            headers: { 'Content-Type': 'application/json' }
        });
        const result = response.data.result;
        const createdObjects = result.effects?.created || [];
        if (createdObjects.length === 0) {
            console.log('未找到新创建的对象');
            return null;
        }

        const newObjectId = createdObjects[0].reference.objectId;
        console.log('新对象 ID:', newObjectId);
        return newObjectId;

    } catch (error: any) {
        console.error('获取新对象失败:', error.message);
        return null;
    }
}

//需要准备足够的gas， error没有一直打印出来，gas不够的error没有区分处理
async function main(){

    // const MNEMONIC = '';// 自己的助记词
    //const keypair = Ed25519Keypair.fromSecretKey(Buffer.from(MNEMONIC, 'hex'));
    
    const keypair = get_keypair_from_keystore();

    const publicKey = keypair.getPublicKey();
    const address = publicKey.toSuiAddress();
    console.log('Wallet Address:', address);

    const client = new SuiClient({ url: suiRpcUrl });
    let balance = await client.getBalance({ owner: address });
    console.log('Account Balance:', balance);

    // let experience = await get_experience(); // ？ slay_boar的Transaction 根本还没有执行呢？
    // console.log("experience: ",experience);
    // return;

    // 升级英雄
    if(true){
        let i = 0;
        while(i<200){ //const HERO_STAMINA: u64 = 200; //hero::decrease_stamina(hero, 1); 每次slay_boar 扣1
            const tx = new Transaction();
            tx.moveCall({
                target: `${PACKAGE_ID}::adventure::slay_boar`,
                arguments: [
                    tx.object(heroId),
                    ]
                });
            let experience = await get_experience(); // ？ slay_boar的Transaction 根本还没有执行呢？
            console.log("experience: ",experience);
            if (experience >= 100){
                tx.moveCall({
                    target: `${PACKAGE_ID}::hero::level_up`,
                    arguments: [tx.object(heroId),]
                });
                const result = await client.signAndExecuteTransaction({signer: keypair,transaction: tx,});
                console.log('Transaction Result:', result);
                break;
            }
            const result = await client.signAndExecuteTransaction({signer: keypair,transaction: tx,});
            console.log('Transaction Result:', result);
        }
    }

    if(true){
        // 初始化balances
        const tx1 = new Transaction();
        tx1.moveCall({
                    target: `${PACKAGE_ID}::adventure::init_balances`,
                    arguments: [tx1.object(userTokenAmountId),]
                });
        const result1 = await client.signAndExecuteTransaction({signer: keypair,transaction: tx1,});
        console.log('Transaction Result:', result1);
    }


    // 打野猪王获取balances
    //每个成功的tx需要大约2.77 Sui, 失败的话需要0.0121 Sui，需要准备足够的gas
    for(let j = 0; j < 10000; j++){//while(true){
        try{
            const tx3 = new Transaction();
            let num = 2047;
            const address1 = address //''// 随便写一个地址
            tx3.moveCall({
                    target: `${PACKAGE_ID}::adventure::new_obj`,
                    arguments: [tx3.pure.u64(num), tx3.pure.address(address1),]
                });
            tx3.moveCall({
                    target: `${PACKAGE_ID}::adventure::slay_boar_king`,
                    arguments: [tx3.object('0x6'), tx3.object(userTokenAmountId), tx3.object(heroId)]
                });
            const result3 = await client.signAndExecuteTransaction({signer: keypair,transaction: tx3,});
            console.log('Transaction Result:', result3);
            let amount = await get_transaction_events(result3.digest);
            // console.log("amount: ",amount);
            if (amount! >= 200) {
                break;
            }else{
                continue;
            }
        }catch(error: any){
            // console.error("打野猪王 error: ", error);
            console.error("打野猪王 error, 一般来说是超2048个obj了");
            continue;
        }
    }

    if(true){
        // buy box
        const tx4 = new Transaction();
        tx4.moveCall({
                    target: `${PACKAGE_ID}::adventure::buy_box`,
                    arguments: [tx4.object(userTokenAmountId),]
                });
        const result4 = await client.signAndExecuteTransaction({signer: keypair,transaction: tx4,});
        console.log('Transaction Result:', result4);
        let newobjectId = await get_newly_created_object(result4.digest);
        if (newobjectId != null){
            // get flag
            const tx5 = new Transaction();
            tx5.moveCall({
                        target: `${PACKAGE_ID}::inventory::get_flag`,
                        arguments: [tx5.object(newobjectId),]
                    });
            const result5 = await client.signAndExecuteTransaction({signer: keypair,transaction: tx5,});
            console.log('Transaction Result:', result5);
            await get_transaction_events(result5.digest);
        }
    }
}

//run
main().catch(console.error);
