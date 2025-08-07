import { Transaction } from '@mysten/sui/transactions';
import { SuiClient, getFullnodeUrl } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { get_keypair_from_keystore, get_newly_created_object, get_transaction_events } from './util';



//local
//启动本地节点： https://docs.sui.io/guides/developer/getting-started/local-network
//RUST_LOG="off,sui_node=info" sui start --with-faucet //--force-regenesis
const env = 'localnet';
const PACKAGE_ID = '0x6b465f93b819898facf85c9c6280c0db5067c61a54a36fa463039b0855443f94';

const obj_type = `${PACKAGE_ID}::boar_slayer::Obj`;

// //testnet
// const env = 'testnet';
// const PACKAGE_ID = '';

//devnet
// const env = 'devnet';
// const PACKAGE_ID = '';

const suiRpcUrl = getFullnodeUrl(env);


async function main(){

    const keypair = get_keypair_from_keystore();

    const publicKey = keypair.getPublicKey();
    const address = publicKey.toSuiAddress();
    console.log('Wallet Address:', address);

    const client = new SuiClient({ url: suiRpcUrl });
    let balance = await client.getBalance({ owner: address });
    console.log('Account Balance:', balance);
    console.log('');



    // // //call move function
    let num = 2047;
    // await create_massive_objects(client, keypair, address, num);


    // 调用封装后的函数
    const allObjs = await getAllOwnedObjectsByType(client, address, obj_type);
    console.log('Owned Obj objects:', allObjs.length); //2067

    // console.log('obj 0:\n', allObjs[0]);
    //obj 0: 
    // {
    //   data: {
    //     objectId: '0x00185f2d3b745786ea79e2f0780904c795174d17fbfd4f532de8027d22197c4f',
    //     version: '8',
    //     digest: 'E5rrB46cj35TBjeHG4f278jfDJbzQwvW1Wex19pzeHCK'
    //   }
    // }

    //burn then create
    await create_massive_objects(client, keypair, address, 100, true, allObjs.slice(0, 1000));



    // let objects = await client.getOwnedObjects({
    //     owner: address,
    //     filter: {
    //         StructType: obj_type
    //     }
    // });
    // console.log('objects:', objects.data.length); //50



    // let objects = await client.devInspectTransactionBlock({
    //     owner: address,
    //     options: {
    //         showType: true,
    //     },
    // });

    // let result = await client.dryRunTransactionBlock({
    //     transaction: tx,
    // });

    // console.log('objects:', objects);
}

 /**
     * 获取指定地址下所有类型为 obj_type 的对象，支持分页获取所有结果
     * @param client SuiClient 实例
     * @param address 钱包地址
     * @param obj_type 对象类型
     * @returns 返回所有对象数组
     */
 async function getAllOwnedObjectsByType(client: SuiClient, address: string, obj_type: string): Promise<any[]> {
    let allObjs: any[] = [];
    let nextCursor: string | null | undefined = null;
    let hasNextPage = true;
    let pageSize = 50; // 50:default; 每页获取50个，可根据需要调整 //1000: JsonRpcError: Page size limit 1000 exceeds max limit 50

    while (hasNextPage) {
        const page = await client.getOwnedObjects({
            owner: address,
            filter: {
                StructType: obj_type
            },
            cursor: nextCursor ?? undefined,
            limit: pageSize,
        });
        allObjs = allObjs.concat(page.data);
        nextCursor = page.nextCursor;
        hasNextPage = page.hasNextPage;
    }
    return allObjs;
}

async function create_massive_objects(client: SuiClient, keypair: Ed25519Keypair, to_address: string, num: number, burn: boolean = false, burn_objects: any[]){

    const tx = new Transaction();

    //burn
    if(burn){
        //JsonRpcError: Error checking transaction input objects: SizeLimitExceeded { limit: "maximum commands in a programmable transaction", value: "1024" }
        for(let i = 0; i < burn_objects.length; i++){
        tx.moveCall({
            target: `${PACKAGE_ID}::boar_slayer::burn`,
            arguments: [tx.object(burn_objects[i].data.objectId),]
            });
        }

        // //move里先修改为数组的arguments
        // // Convert burn_objects to a list of object IDs
        // const burn_object_ids = burn_objects.map(obj => tx.object(obj.data.objectId));
        // tx.moveCall({
        //     target: `${PACKAGE_ID}::boar_slayer::burn`,
        //     arguments: burn_object_ids
        // });
    }


    tx.moveCall({
            target: `${PACKAGE_ID}::boar_slayer::new_obj`,
            arguments: [tx.pure.u64(num), tx.pure.address(to_address),]
        });


    const result = await client.signAndExecuteTransaction({signer: keypair,transaction: tx,});
    console.log('create_massive_objects tx:', result);


    //wait
    const result1 = await client.waitForTransaction({
        digest: result.digest,
        options: {
            showEvents: true,
        },
    });

    console.log('create_massive_objects waitForTransaction:', result1);

    // let events = await get_transaction_events(suiRpcUrl, result.digest);
    // console.log('create_massive_objects events:', events);
}


//run
main().catch(console.error);