
const axios = require('axios');
const { fetchAllCosmosDbCollections, readFailedRecordsFromCollection } = require('../common/cosmos');
const ACTIVITY_APP_ENDPOINT_OUTBOUND = process.env['ACTIVITY_APP_ENDPOINT_OUTBOUND'];
const PAGINATION_INTERVAL = process.env['PAGINATION_INTERVAL'] | 5;

const main = async context => {
    const statusArr = [200, 201, 202];

    const mainCollections = await fetchAllCosmosDbCollections(context);
    context.log('mainCollections:', mainCollections);
    for (const collectionName of mainCollections) {
        let continuationToken;
        do {
            const result = await readFailedRecordsFromCollection(context, collectionName, continuationToken);
            const items = result.items;
            continuationToken = result.nextContinuationToken;
            context.log(`collection: ${collectionName}, itemCount: ${items.length}, continuation: ${continuationToken}`);
            for (const item of items) {
                const triggerURI = ACTIVITY_APP_ENDPOINT_OUTBOUND;

                context.log('Trigger URI:', triggerURI);
                const triggerOptions = {
                    headers: { 'Content-Type': `application/json` }
                };

                const record = Object.assign({}, item);
                delete record.edi;
                delete record.id;
                delete record.partitionKey;
                for (const key of Object.keys(record)) {
                    if (key.startsWith('_')) {
                        delete record[key];
                    }
                }

                const triggerResponse = await axios.post(triggerURI, record, triggerOptions).catch(err => {
                    context.log.error(`Failed to trigger. ${err.stack}`);
                });
                if (triggerResponse && statusArr.includes(triggerResponse.status)) {
                    context.log.info(`Activity retriggered succesfully for record with id: ${item.id}, partitionKey: ${item.partitionKey}`);
                }
            }
            await new Promise(resolve => setTimeout(resolve, PAGINATION_INTERVAL));
        } while (continuationToken);

    }
};

module.exports = async function (context, myTimer) {
    const timeStamp = new Date().toISOString();

    if (myTimer.isPastDue) {
        context.log('JavaScript is running late!');
    }
    context.log('JavaScript timer trigger function ran!', timeStamp);

    await main(context);
};
