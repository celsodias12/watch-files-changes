# Instructions

Run the following command:

```bash
watch-files-changes -i "node_modules,.git,.gitignore,pnpm-lock.yaml,package.json" -d "." -c "node app.js"
```

`-i "node_modules,.git,.gitignore,pnpm-lock.yaml,package.json"` -> in this case we are ignoring the changes in the following folders and files: `node_modules,.git,.gitignore,pnpm-lock.yaml,package.json`

`-d "."` -> estamos olhando para o diretório inteiro com a opção `"."`

`-c "node app.js"` -> after any change according to what was defined earlier, we run the command `node app.js`
