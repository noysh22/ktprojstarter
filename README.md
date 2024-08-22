# Starter template for Kotlin Javalin in Bazel

## Start the server

```bash
bazel run //:server
```


## Create a new project from this template

run the `create-proj.sh` script from the root of this directory

```bash
./create-proj.sh NewName dst-folder
```

### monorepos

If you want to use this template to create a new project / service
in a monorepo use the -m | --monorepo flag

```bash
./create-proj.sh --monorepo NewName dst-folder
```

## TODO

 - Add protobuf server (separate branch?)
 - Add tests to main branch
 - Add a branch with gradle and wasm in a separate branch