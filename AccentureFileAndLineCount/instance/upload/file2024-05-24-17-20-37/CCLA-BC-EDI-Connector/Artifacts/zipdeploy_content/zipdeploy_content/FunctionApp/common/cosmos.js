
const CosmosClient = require('@azure/cosmos').CosmosClient;
const { DefaultAzureCredential } = require('@azure/identity');

// Cosmos key values
const cosmosAccountHost = process.env['COSMOS_ACCOUNT_HOST'];
const cosmosAccountDB = process.env['COSMOS_ACCOUNT_DB'];
const cosmosDefaultCollection = process.env['COSMOS_DEFAULT_COLLECTION'] || 'outboundevent';
const connStr = `${cosmosAccountHost}`;
const enableHistoryFeed = process.env['ENABLE_HISTORY_FEED'] || false;

const DATETIME_DIFF = process.env['DATETIME_DIFF'] || 'mi';
const DATETIME_DIFF_VALUE = process.env['DATETIME_DIFF_VALUE'] || 240;
const MAX_DELIVERY_COUNT = process.env['MAX_DELIVERY_COUNT'] || 5;
const ACK_FAILED_STATUS_CODE = process.env['ACK_FAILED_STATUS_CODE'] || 4;
const REPROCESS_STATUS_CODES = process.env['REPROCESS_STATUS_CODES'] || '0, 1, 5';
const MAX_PAGE_COUNT = process.env['MAX_PAGE_COUNT'] || 50;

// Cosmos update interval
const unixTimeDeno = 1000;

// Cosmos DB scope
const defaultScope = 'https://database.windows.net/.default';
const cosmosDbScope = process.env['COSMOS_DB_SCOPE'] || defaultScope;

// Cosmos client
let client;
let credential;
let uti;
const MAX_RETRY_COUNT = 5;
// 5 seconds timeout value
const TIMEOUT_VAL = 5000;

// Token Checker
const defaultTokenRenewTimePriorExpiry = 300000;
const tokenLifeLimit = process.env['TOKEN_RENEW_TIME'] || defaultTokenRenewTimePriorExpiry;

// const getClientInstance = () => {
//     //Check if the Cosmos Client instance exists
//     if (!client) {
//         // Create new Cosmos Client instance
//         client = new CosmosClient(connStr);
//     } else {
//         // Found existing Cosmos Client instance
//     }
//     return client;
// };

const parseToken = token => JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());

const getTokenDetails = async () => {
    const tokenDetails = await credential.getToken(cosmosDbScope);
    return parseToken(tokenDetails.token);
};

const getClientInstance = async (context, retryCount = 0) => {
    try {
        if (!client) {
            // Create new Cosmos Client instance
            context.log.info('Initializing Cosmos Client Context');
            credential = new DefaultAzureCredential();
            client = new CosmosClient({ endpoint: connStr, aadCredentials: credential });
            const accessTokenDetails = await getTokenDetails();
            uti = accessTokenDetails.uti;
            const expiry = accessTokenDetails.exp;
            context.log.info(`Expiry of the obtained token: ${expiry}`);
            const timeDiff = new Date((new Date(expiry * unixTimeDeno)).toISOString()) - new Date(new Date().toISOString());
            if (timeDiff < tokenLifeLimit) {
                context.log.info(`RESETING COSMOS CLIENT ==> Reason : ExpiredToken : ${timeDiff < tokenLifeLimit}`);
                await new Promise(resolve => setTimeout(resolve, TIMEOUT_VAL));
                client.dispose();
                client = null;
                credential = null;
                await getClientInstance(context);
            } else {
                context.log.info(`RESETING COSMOS CLIENT Completed ==> ExpiredToken : ${timeDiff < tokenLifeLimit}`);
            }
        } else {
            // Found existing Cosmos Client instance
            const { exp, uti: uti1 } = await getTokenDetails();
            const timeDiff = new Date((new Date(exp * unixTimeDeno)).toISOString()) - new Date(new Date().toISOString());
            if (timeDiff < tokenLifeLimit || uti !== uti1) {
                context.log.info(`RESETING COSMOS CLIENT ==> Reason : ExpiredToken : ${timeDiff < tokenLifeLimit}, UTI CHANGE : ${uti !== uti1}`);
                client.dispose();
                client = null;
                credential = null;
                await getClientInstance(context);
            }
        }
    } catch (error) {
        context.log.warn(`Exception occurred in Cosmos.getClientInstance method: ${error.stack}`);
        ++retryCount;
        if (retryCount < MAX_RETRY_COUNT) {
            context.log.info(`Cosmos.getClientInstance ... retrying with delay of ${TIMEOUT_VAL}ms, retryCount: ${retryCount}!`);
            await new Promise(resolve => setTimeout(resolve, TIMEOUT_VAL));
            return getClientInstance(context, retryCount);
        } else {
            context.log.warn(`Cosmos.getClientInstance ... retry count exceeded!`);
            throw error;
        }
    }
    return client;
};

const fetchAllCosmosDbCollections = async function (context) {
    const collections = [];
    try {
        client = await getClientInstance(context);
        //Fetch the Cosmos Collection instance.
        const { resources } = await client.database(cosmosAccountDB).containers.readAll().fetchAll();
        for (const col of resources) {
            if (!col.id.includes('history') && col.id.startsWith(cosmosDefaultCollection)) {
                collections.push(col.id);
            }
        }
    } catch (err) {
        throw new Error(`Failed to fetch collections`, err);
    }
    return collections;
};

const fetchCosmosDbCollection = async function (context, collectionName) {
    let collection;
    try {
        client = await getClientInstance(context);
        //Fetch the Cosmos Collection instance.
        collection = client.database(cosmosAccountDB).container(collectionName);

    } catch (err) {
        throw new Error(`Failed to initialize collection ${collectionName}`, err);
    }
    return collection;
};

const readRecordsFromCollection = async function (context, collectionName, primaryKeyValue, partitionKeyValue) {
    context.log.info(`readRecordsFromCollection() called. Reading record in collection ${collectionName} with id ${primaryKeyValue} and partitionKey ${partitionKeyValue}...`);
    let error = '';
    const headerRequest = 'x-ms-request-charge';
    try {
        const collection = await fetchCosmosDbCollection(context, collectionName);
        const query = {
            query: `SELECT * FROM c WHERE c.id='${primaryKeyValue}' and c.partitionKey='${partitionKeyValue}' OFFSET 0 LIMIT 1`
        };
        const { resources: items, headers } = await collection.items
            .query(query)
            .fetchAll();
        const item = items[0];
        const responseHeader = headers;
        context.log.info(`Read RU consumed: ${responseHeader[headerRequest]}`);
        return item;
    } catch (err) {
        error = 'readRecordsFromCollection error stack: ' + err.stack;
        throw new Error(error);
    }
};

const readFailedRecordsFromCollection = async function (context, collectionName, continuationToken) {
    let error = '';
    const headerRequest = 'x-ms-request-charge';
    const headerContinuationToken = 'x-ms-continuation';
    // const criteria1 = `c.edi.statusCode IN (${REPROCESS_STATUS_CODES}) and DateTimeDiff('${DATETIME_DIFF}', c.edi.lastUpdateDateTime, '${new Date().toISOString()}') > ${DATETIME_DIFF_VALUE}`;
    const criteria2 = `c.edi.statusCode = ${ACK_FAILED_STATUS_CODE} and c.edi.deliveryCount < ${MAX_DELIVERY_COUNT}`;
    try {
        const collection = await fetchCosmosDbCollection(context, collectionName);
        const query = {
            query: `SELECT * FROM c WHERE (${criteria2})`
        };
        const { resources: items, headers } = await collection.items
            .query(query, {
                maxItemCount: 1,
                partitionKey: collection.partitionKey,
                continuationToken
            }).fetchNext();
        const responseHeader = headers;
        context.log.info(`Read RU consumed: ${responseHeader[headerRequest]}`);
        return { items, nextContinuationToken: responseHeader[headerContinuationToken] };
    } catch (err) {
        error = 'readFailedRecordsFromCollection error stack: ' + err.stack;
        throw new Error(error);
    }
};

const insertCosmosRecord = async function (context, params) {
    const { collectionName, partitionKey, assetRecord, prefix, isHistory } = params;
    context.log.info(`insertCosmosRecord() called. Inserting record in collection ${collectionName} with id ${assetRecord.data.objectId} and partitionKey ${partitionKey}...`);
    let res = false;
    let error = '';
    const headerRequest = 'x-ms-request-charge';
    try {
        assetRecord['id'] = `${prefix}|${assetRecord.data.objectId}`;
        assetRecord['partitionKey'] = partitionKey;
        const data = { 'deliveryCount': 0, createdDateTime: new Date().toISOString(), statusCode: 0 };
        assetRecord['edi'] = data;
        const collection = await fetchCosmosDbCollection(context, collectionName);

        context.log(assetRecord);
        const { resource: createdItem, headers } = await collection.items.create(assetRecord);

        if (createdItem) {
            context.log.info(`Insert RU consumed: ${headers[headerRequest]}`);
            if (JSON.parse(enableHistoryFeed) && !isHistory) {
                const recordWithHistory = Object.assign({}, assetRecord);
                recordWithHistory.history = [data];
                await insertCosmosRecord(context, { collectionName: `${collectionName}_history`, partitionKey, assetRecord: recordWithHistory, prefix, isHistory: true });
            }
            res = true;
        } else {
            error = `Failed to create record in collection ${collectionName} for id ${assetRecord['id']}.`;
        }
    } catch (err) {
        error = 'insertCosmosRecord error stack: ' + err.stack;
        throw new Error(error);
    }
    return res;
};

module.exports = {
    fetchAllCosmosDbCollections,
    readRecordsFromCollection,
    readFailedRecordsFromCollection,
    insertCosmosRecord
};
