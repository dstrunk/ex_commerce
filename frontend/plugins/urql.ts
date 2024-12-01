import {
    createClient,
    cacheExchange,
    fetchExchange,
    ssrExchange,
    subscriptionExchange,
    type SSRData,
    type Operation,
} from '@urql/vue';
import { createClient as createWSClient } from 'graphql-ws';
import { authExchange } from '@urql/exchange-auth';

export default defineNuxtPlugin((nuxtApp) => {
    const { public: { websocketUrl, apiUrl } } = useRuntimeConfig();
    const ssrKey: string = '__URQL_DATA__';

    const ssr = ssrExchange({
        isClient: import.meta.client,
    });

    const exchanges = [
        cacheExchange,
        ssr,
        authExchange(async (utils) => {
            const token = import.meta.client
                ? window?.localStorage?.getItem('excommerce_token')
                : null;

            return {
                addAuthToOperation(operation: Operation): Operation {
                    if (!token) {
                        return operation;
                    }

                    return utils.appendHeaders(operation, {
                        Authorization: `Bearer ${token}`,
                    });
                },

                didAuthError(error, operation) {
                    return error.graphQLErrors.some((e) => e.extensions?.code === 'FORBIDDEN');
                },

                async refreshAuth() {
                    // @TODO add refresh token mutation here
                },
            };
        }),
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

    nuxtApp.vueApp.provide('$urql', ref(client));

    if (import.meta.client) {
        nuxtApp.hook('app:created', () => {
            ssr.restoreData(nuxtApp.payload[ssrKey] as SSRData);
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
