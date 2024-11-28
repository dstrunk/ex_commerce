import { defineStore } from '#imports';
import type { User } from '~/types/graphql/graphql';
import { useMutation } from '@urql/vue';
import { LoginDocument, RegisterDocument } from '~/types/graphql/graphql';

const useCustomerStore = defineStore('customer', () => {
    const customer = ref<User | null>(() => null);

    const { data: loginData, executeMutation: executeLogin } = useMutation(LoginDocument);

    interface LoginProps {
        email: string;
        password: string;
    }

    const login = async ({ email, password }: LoginProps) => {
        const result = await executeLogin({ email, password });
        if (result?.error) {
            // @TODO add error messaging
            return;
        }

        customer.value = loginData.value?.user;
    };

    const logout = async () => {
        customer.value = null;
    };

    const { data: registrationData, executeMutation: executeRegistration } = useMutation(RegisterDocument);

    interface RegistrationProps {
        firstName: string;
        lastName: string;
        email: string;
        password: string;
    }

    const register = async ({ firstName, lastName, email, password }: RegistrationProps) => {
        const result = await executeRegistration({ input: { firstName, lastName, email, password } });
        if (result?.error) {
            // @TODO add error messaging
            return;
        }

        customer.value = registrationData.value?.user;
    };

    return {
        customer,

        login,
        logout,
        register,
    };
});
