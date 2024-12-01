import { defineStore } from '#imports';

const slugify = (str: string) => {
    return str
        .toLowerCase()
        .replace(/ /g, '-')
        .replace(/[^\w-]+/g, '')
        .replace(/--+/g, '-')
        .replace(/^-+/, '')
        .replace(/-+$/, '');
}

export enum ErrorLevel {
    Info = 'info',
    Warning = 'warning',
    Error = 'error',
}

interface Error {
    title: string;
    message: string;
    level: ErrorLevel;
}

/**
 * Handles server-side errors, or errors that may occur outside FormKit errors.
 * Typically meant to be used inside other stores, but also for escape hatch error messages.
 * @param path
 */
export const useErrorsStore = (path: string) => {
    const storeId = `errors-${slugify(path)}`;

    return defineStore(storeId, () => {
        const errors = ref<Error[]>([]);

        const addError = (error: Error) => {
            errors.value.push(error);
        };

        const addErrors = (errors: Error[]) => {
            errors.forEach((error) => addError(error));
        };

        const resetErrors = () => {
            errors.value = [];
        };

        return {
            errors,

            addError,
            addErrors,
            resetErrors,
        };
    })();
};
