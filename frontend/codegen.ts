import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
    use: {
        ignoreHTTPSErrors: true,
    },
    schema: 'http://backend:4000/',
    documents: ['./graphql/**/*.gql'],
    generates: {
        './types/graphql/': {
            preset: 'client',
            config: {
                useTypeImports: true,
            },
        },
    },
};

export default config;
