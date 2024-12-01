import { defineStore } from '#imports';
import { useMutation, useQuery } from '@urql/vue';
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

    onMounted(async () => {
        if (isLoggedIn.value && !user.value) {
            await executeSessionQuery();
            user.value = useFragment(UserFieldsFragmentDoc, userData.value?.me) || null;
        }
    });

    watch(isLoggedIn, async () => {
        if (isLoggedIn.value && !user.value) {
            await executeSessionQuery();
            user.value = useFragment(UserFieldsFragmentDoc, userData.value?.me) || null;
        }
    });

    const errorStore = useErrorsStore('user');
    const { errors } = storeToRefs(errorStore);
    const hasErrors = computed(() => errors.value?.length > 0);

    const { data: userData, executeQuery: executeSessionQuery } = useQuery<SessionQuery>({ query: SessionDocument, pause: true });
    const { data: loginData, executeMutation: executeLogin } = useMutation<LoginMutation>(LoginDocument);
    const { data: registrationData, executeMutation: executeRegistration } = useMutation<RegistrationMutation>(RegistrationDocument);
    const { data: refreshTokenData, executeMutation: executeTokenRefresh } = useMutation<RefreshTokenMutation>(RefreshTokenDocument);

    const login = async ({ email, password }: { email: string; password: string }) => {
        resetErrors();

        const result = await executeLogin({ email, password });
        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, loginData.value?.login?.me) || null;
        window?.localStorage?.setItem('excommerce_token', loginData.value?.login?.token ?? '');
    };

    const logout = async () => {
        resetErrors();

        user.value = null;
        window?.localStorage?.removeItem('excommerce_token');
    };

    const register = async ({ firstName, lastName, email, password }: { firstName: string; lastName: string; email: string; password: string }) => {
        resetErrors();

        const result = await executeRegistration({ firstName, lastName, email, password });
        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, registrationData.value?.register?.me) || null;
        window?.localStorage?.setItem('excommerce_token', registrationData.value?.register?.token ?? '');
    };

    const refreshToken = async () => {
        resetErrors();

        const result = await executeTokenRefresh();
        if (result?.error) {
            return errorStore.addError({
                title: '',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        user.value = useFragment(UserFieldsFragmentDoc, refreshTokenData.value?.refreshToken?.me) || null;
        window?.localStorage?.setItem('excommerce_token', refreshTokenData.value?.refreshToken?.token ?? '');
    }

    const resetErrors = () => {
        errorStore.resetErrors();
    };

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
