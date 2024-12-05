<template>
    <CartDrawerItem v-for="item in items" />
</template>

<script setup lang="ts">
import { useCartStore } from '~/stores/Cart';

    const cartStore = useCartStore();
    const { items } = storeToRefs(cartStore);
</script>
