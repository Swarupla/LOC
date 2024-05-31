
const axios = require('axios');
const { insertCosmosRecord, readRecordsFromCollection } = require('../common/cosmos');
const transactionCode = require('./transactioncode.json');
const cosmosDefaultCollection = process.env['COSMOS_DEFAULT_COLLECTION'] || 'outboundevent';

const ACTIVITY_APP_ENDPOINT_OUTBOUND = process.env['ACTIVITY_APP_ENDPOINT_OUTBOUND'];

const triggerActivity = async (context, message) => {
    let jsonMessage;
    if (typeof message == 'string') {
        jsonMessage = JSON.parse(message);
    } else {
        jsonMessage = message;
    }

    const collectionName = cosmosDefaultCollection;

    const partitionKey = transactionCode.filter(x => x.eventType === jsonMessage.eventType)[0].code;
    const prefix = transactionCode.filter(x => x.eventType === jsonMessage.eventType)[0].prefix;

    const id = `${prefix}|${jsonMessage.data.objectId}`;

    const record = await readRecordsFromCollection(context, collectionName, id, partitionKey);
    if (!record) {
        const assetRecord = Object.assign({}, jsonMessage);
        const res = await insertCosmosRecord(context, { collectionName, partitionKey, assetRecord, prefix });
        if (res) {
            context.log('Record saved successfully.', jsonMessage);
        } else {
            context.log.warn('Failed saving record.', jsonMessage);
        }
    }

    const tokenResponse = await axios.post(ACTIVITY_APP_ENDPOINT_OUTBOUND, jsonMessage);

    const statusArr = [200, 201, 202];
    if (tokenResponse && statusArr.includes(tokenResponse.status)) {
        context.log.info('Activity initiated succesfully!');
    }

};

module.exports = async function (context, mySbMsg) {
    context.log('JavaScript ServiceBus queue trigger function processed message');
    try {
        await triggerActivity(context, mySbMsg);
    } catch (err) {
        throw new Error(err);
    }
};
