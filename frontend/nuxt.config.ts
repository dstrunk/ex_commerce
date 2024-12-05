// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    compatibilityDate: "2024-04-03",
    modules: ["@nuxt/test-utils/module", "@formkit/nuxt", "@pinia/nuxt"],
    devtools: { enabled: true },
    runtimeConfig: {
        public: {
            apiUrl: process.env.API_URL || 'https://api.excommerce.test/',
            websocketUrl: process.env.WEBSOCKET_URL || 'wss://api.excommerce.test/',
        },
    },
    css: ["~/assets/css/app.css"],
    postcss: {
        plugins: {
            tailwindcss: {},
            autoprefixer: {},
        },
    },
    formkit: {
        autoImport: true,
    },
    pinia: {
        storesDirs: ["./stores/**"],
    },
    vite: {
        server: {
            hmr: {
                protocol: "wss",
                host: "https://excommerce.test:3000",
            },
        },
    },
    routeRules: {
        '/': { prerender: true },
        '/account/**': { ssr: false },
        '/account/login': { prerender: true },
        '/account/register': { prerender: true },
        '/products': { swr: true },
        '/products/**': { swr: 3600 },
    },
});
