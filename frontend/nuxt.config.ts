// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    compatibilityDate: '2024-04-03',
    modules: [
        '@nuxt/test-utils/module',
        '@formkit/nuxt',
    ],
    devtools: { enabled: true },
    runtimeConfig: {
        public: {
            apiUrl: process.env.API_URL,
            websocketUrl: process.env.WEBSOCKET_URL,
        },
    },
    css: ['~/assets/css/app.css'],
    postcss: {
        plugins: {
            tailwindcss: {},
            autoprefixer: {},
        },
    },
    formkit: {
        autoImport: true,
    },
});
