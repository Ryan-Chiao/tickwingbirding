/** @type {import('eslint').Linter.Config} */
module.exports = {
  extends: ['@tickwing/eslint-config'],
  parserOptions: {
    project: './tsconfig.json',
    tsconfigRootDir: __dirname,
  },
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'warn',
  },
};
