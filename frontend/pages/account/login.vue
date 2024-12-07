<template>
    <div class="max-w-lg">
        <h2>Login</h2>
        <p v-if="hasErrors" v-for="error in errors" :key="error.message" v-text="error.message" />
        <FormKit type="form" @submit="submit" :actions="false">
            <FormKit
                type="text"
                name="email"
                label="Email"
                placeholder="jane.doe@example.com"
                validation="required|email"
            />
            <FormKit
                type="password"
                name="password"
                label="Password"
                validation="required"
            />
            <FormKit
                type="submit"
                label="Login"
            />
        </FormKit>
    </div>
</template>

<script setup lang="ts">
import { useCustomerStore } from '~/stores/Customer';
import { definePageMeta } from '#imports';
import { navigateTo } from '#app';

definePageMeta({
    middleware: ['logged-in'],
})

const customerStore = useCustomerStore();
const { errors, hasErrors } = storeToRefs(customerStore);

interface LoginFormProps {
    email: string;
    password: string;
}

const submit = async ({ email, password }: LoginFormProps) => {
    await customerStore.login({ email, password });

    navigateTo('/account/overview');
};
</script>
