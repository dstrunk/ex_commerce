import { defineStore } from '#imports';
import { useQuery, useMutation } from '@urql/vue';
import type {
    LoginMutation,
    RefreshTokenMutation,
    RegistrationMutation,
    SessionQuery,
    User
} from '~/types/graphql/graphql';
import {
    LoginDocument,
    RefreshTokenDocument,
    RegistrationDocument,
    SessionDocument,
    UserFieldsFragmentDoc,
} from '~/types/graphql/graphql';
import { ErrorLevel, useErrorsStore } from '~/stores/Errors';
import { useFragment } from '~/types/graphql';

export const useUserStore = defineStore('user', () => {
    const user = ref<User | null>(null);
    const token = computed(() => window?.localStorage?.getItem('excommerce_token') || null);
    const isLoggedIn = computed(() => !!token.value);

    const errorStore = useErrorsStore('user');
    const { errors } = storeToRefs(errorStore);
    const hasErrors = computed(() => errors.value?.length > 0);
    const resetErrors = () => errorStore.resetErrors();

    const loginMutation = () => useMutation<LoginMutation>(LoginDocument);
    const registrationMutation = () => useMutation<RegistrationMutation>(RegistrationDocument);
    const refreshTokenMutation = () => useMutation<RefreshTokenMutation>(RefreshTokenDocument);
    const sessionQuery = () => useQuery<SessionQuery>({ query: SessionDocument, pause: true });

    const login = async ({ email, password }: { email: string; password: string }) => {
        resetErrors();

        const { executeMutation, data } = loginMutation();
        const result = await executeMutation({ email, password });

        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, data.value?.login?.me) || null;
        window?.localStorage?.setItem('excommerce_token', data.value?.login?.token ?? '');
    };

    const logout = async () => {
        resetErrors();

        user.value = null;
        window?.localStorage?.removeItem('excommerce_token');
    };

    const register = async ({ firstName, lastName, email, password }: { firstName: string; lastName: string; email: string; password: string }) => {
        resetErrors();

        const { executeMutation, data } = registrationMutation();
        const result = await executeMutation({ firstName, lastName, email, password });

        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, data.value?.register?.me) || null;
        window?.localStorage?.setItem('excommerce_token', data.value?.register?.token ?? '');
    };

    const refreshToken = async () => {
        resetErrors();

        const { executeMutation, data } = refreshTokenMutation();
        const result = await executeMutation();

        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, data.value?.refreshToken?.me) || null;
        window?.localStorage?.setItem('excommerce_token', data.value?.refreshToken?.token ?? '');
    }

    const fetchSession = async () => {
        const { executeQuery, data } = sessionQuery();
        await executeQuery();
        user.value = useFragment(UserFieldsFragmentDoc, data.value?.me) || null;
    }

    watch(isLoggedIn, async (newValue) => {
        if (newValue && !user.value) {
            await fetchSession();
        }
    });

    onMounted(async () => {
        if (isLoggedIn.value && !user.value) {
            await fetchSession();
        }
    });

    return {
        user,
        token,
        isLoggedIn,

        login,
        logout,
        register,
        refreshToken,

        errors,
        hasErrors,
        resetErrors,
    };
});
