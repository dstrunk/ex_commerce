<template>
    <h1>Overview</h1>
    <h2>Welcome {{ user?.fullName }}!</h2>
    <button @click="logout">
        Log out
    </button>
</template>

<script setup lang="ts">
import { definePageMeta } from '#imports';

definePageMeta({
    middleware: ['auth'],
});

const userStore = useUserStore();
const { user } = storeToRefs(userStore);

const logout = () => {
    userStore.logout();

    navigateTo('/account/login');
}
</script>
