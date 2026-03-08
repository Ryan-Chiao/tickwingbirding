/** @type {import('eslint').Linter.Config} */
module.exports = {
  extends: ['@tickwing/eslint-config', 'next/core-web-vitals'],
  parserOptions: {
    project: './tsconfig.json',
    tsconfigRootDir: __dirname,
  },
};
