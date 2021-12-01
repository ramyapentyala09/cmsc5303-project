module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  parserOptions: {
    ecmaVersion: 7,
    sourceType: "module",
  },
  rules: {
    quotes: ["error", "double"],
  },
};
