# Watch Files Changes

With this package whenever you edit a file or project, it will be automatically recharged with each change, regardless of the programming language or file extension (including if the file has no extension).

It also works if your command runs an http server or similar.

Tested on distribution derived from Debian.

## Install

Execute install script:

```bash
curl -SsL https://raw.githubusercontent.com/celsodias12/watch-files-changes/main/package/install.sh | bash
```

## Usage

See the readme file for each example in this [folder](./examples/).

```bash
# with shell script
# will observe changes only in the myScript.sh file
# when there are changes in the myScript.sh file, it will run the command "./myScript.sh"
watch-files-changes -d "myScript.sh" -c "./myScript.sh"

# with node
# will notice any changes within the ./examples/app directory
# when there are changes in the ./examples/app directory, it will run the command "node ./examples/app/app.js"
# note that in this case we are ignoring the folders and files "node_modules,.git,.gitignore"
watch-files-changes -i "node_modules,.git,.gitignore" -d "./examples/app" -c "node ./examples/app/app.js"
```

To see the available options run:

```bash
watch-files-changes -h
```

## Unnistall

Execute remove script:

```bash
curl -SsL https://raw.githubusercontent.com/celsodias12/watch-files-changes/main/package/remove.sh | bash
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
