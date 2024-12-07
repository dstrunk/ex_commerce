<template>
    <div class="max-w-lg">
        <h2>Register</h2>
        <p v-if="hasErrors" v-for="error in errors" :key="error.message" v-text="error.message" />
        <FormKit type="form" @submit="submit" :actions="false">
            <FormKit
                type="text"
                name="firstName"
                label="First Name"
                placeholder="Jane"
                validation="required"
            />
            <FormKit
                type="text"
                name="lastName"
                label="Last Name"
                placeholder="Doe"
                validation="required"
            />
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
                type="password"
                name="passwordConfirmation"
                label="Confirm Password"
                validation="required|confirm:password"
            />
            <FormKit
                type="submit"
                label="Register"
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

interface RegistrationFormProps {
    firstName: string;
    lastName: string;
    email: string;
    password: string;
    passwordConfirmation: string;
}

const submit = async ({ firstName, lastName, email, password }: RegistrationFormProps) => {
    await customerStore.register({ firstName, lastName, email, password });

    navigateTo('/account/overview');
};
</script>
