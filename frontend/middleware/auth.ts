import { defineNuxtRouteMiddleware, useNuxtApp } from '#app';

export default defineNuxtRouteMiddleware((_to, _from) => {
    if (import.meta.server) {
        return;
    }

    const token = window?.localStorage?.getItem('excommerce_token');

    if (!token) {
        return navigateTo('/account/login');
    }
});
