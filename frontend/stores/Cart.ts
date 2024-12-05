import { useMutation } from '@urql/vue';
import type { Cart, CartItemInput, UpdateCartItemsMutation } from '~/types/graphql/graphql';
import { CartFieldsFragmentDoc, UpdateCartItemsDocument } from '~/types/graphql/graphql';
import { useFragment } from '~/types/graphql';
import { ErrorLevel, useErrorsStore } from '~/stores/Errors';

export const useCartStore = defineStore('cart', () => {
    const cart = ref<Cart | null>(null);
    const isCartEmpty = computed(() => cart.value?.items?.length === 0);

    const errorStore = useErrorsStore('cart');
    const { errors } = storeToRefs(errorStore);
    const hasErrors = computed(() => errors.value?.length > 0);
    const resetErrors = () => errorStore.resetErrors();

    const updateCartMutation = () => useMutation<UpdateCartItemsMutation>(UpdateCartItemsDocument);

    const addItem = async ({ productId, quantity }: CartItemInput) => {
        resetErrors();

        const { executeMutation, data } = updateCartMutation();
        const result = await executeMutation({ items: [ { productId, quantity } ] });

        if (result?.error) {
            return errorStore.addError({
                title: 'An error occurred while attempting to add your product to the cart. Please try again.',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        cart.value = useFragment(CartFieldsFragmentDoc, data.value?.cart) || null;
    };

    const updateItem = async ({ productId, quantity }: CartItemInput) => {
        resetErrors();

        const { executeMutation, data } = updateCartMutation();
        const result = await executeMutation({ items: [ { productId, quantity } ] });

        if (result?.error) {
            return errorStore.addError({
                title: 'An error occurred while attempting to update your product. Please try again.',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        cart.value = useFragment(CartFieldsFragmentDoc, data.value?.cart) || null;
    }

    const removeItem = async ({ productId }: Omit<CartItemInput, 'quantity'>) => {
        resetErrors();

        const { executeMutation, data } = updateCartMutation();
        const result = await executeMutation({ items: [ { productId, quantity: 0 } ] });

        if (result?.error) {
            return errorStore.addError({
                title: 'An error occurred while attempting to remove your product. Please try again.',
                message: result.error.message,
                level: ErrorLevel.Info,
            });
        }

        cart.value = useFragment(CartFieldsFragmentDoc, data.value?.cart) || null;
    };

    return {
        cart,
        isCartEmpty,

        errors,
        hasErrors,
        resetErrors,

        addItem,
        updateItem,
        removeItem,
    };
});
