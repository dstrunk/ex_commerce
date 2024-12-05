import { defineStore } from '#imports';

const useProductsStore = defineStore('products', () => {
    const products = ref([]);

    interface GetProductNodes {
        limit: number;
    }

    const getNextProducts = async ({ limit }: GetProductNodes) => {
        await Promise.resolve();
    };

    const getPreviousProducts = async ({ limit }: GetProductNodes) => {
        await Promise.resolve();
    };

    return {
        products,

        getNextProducts,
        getPreviousProducts,
    };
});
