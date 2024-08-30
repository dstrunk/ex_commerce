import {
    createClient,
    cacheExchange,
    fetchExchange,
    ssrExchange,
    subscriptionExchange,
} from '@urql/vue';
import { createClient as createWSClient } from 'graphql-ws';

export default defineNuxtPlugin((nuxtApp) => {
    const { public: { websocketUrl, apiUrl } } = useRuntimeConfig();
    const ssrKey = '__URQL_DATA__';

    const ssr = ssrExchange({
        isClient: import.meta.client,
    });

    const exchanges = [
        cacheExchange,
        ssr,
        fetchExchange,
    ];

    if (import.meta.client) {
        const wsClient = createWSClient({
            url: websocketUrl,
        });

        exchanges.push(
            subscriptionExchange({
                forwardSubscription(request) {
                    const input = { ...request, query: request.query || '' }

                    return {
                        subscribe(sink) {
                            const unsubscribe = wsClient.subscribe(input, sink)
                            return { unsubscribe }
                        },
                    };
                },
            }),
        );
    }

    const client = createClient({
        url: apiUrl,
        exchanges,
    });

    nuxtApp.vueApp.provide('$urql', client);

    if (import.meta.client) {
        nuxtApp.hook('app:created', () => {
            ssr.restoreData(window[ssrKey]);
        });
    }

    if (import.meta.server) {
        nuxtApp.hook('app:rendered', () => {
            nuxtApp.payload[ssrKey] = ssr.extractData();
        });
    }

    return {
        provide: {
            urql: client,
        },
    };
});
