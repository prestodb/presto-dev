# Presto Development Environment

This directory contains the necessary files to set up a Docker-based development environment for Presto.

## Prerequisites

*   Docker or podman must be installed and running.

## Quick start

This environment can be run using either CentOS or Ubuntu.

You need checkout this repo under your presto directory

```sh
# Checkout presto-dev under presto directory
git clone https://github.com/unidevel/presto-dev.git

# Start the docker container
cd presto-dev
make start

# Enter shell
make shell
```

## Start presto & prestissimo server

```sh
# Start container shell
make shell

# Start presto coordinator
cd /opt/presto
nohup ./entrypoint.sh &

# Start prestissimo worker
cd /opt/prestissimo
nohup ./entrypoint.sh &

# Build presto (.m2 already cached)
cd /presto
./mvnw clean install -DskipTests

# Build prestissimo(make debug or make release)
cd /presto/presto-native-execution
make
```

Then you can use http://localhost:8080 to open presto console

## Dev with vscode

1. Install [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension
2. Open `Remote Explorer` panel, switch to `Dev Containers` from the dropdown widget on the top
3. Open the `/presto` directory in the composed container `presto-dev` (Make sure clean your local presto project, otherwist it will take a long time to import maven projects)
4. Install microsoft `Extension Pack for Java` and `C/C++ Extension Pack`
4. Start presto & prestissimo in the container
5. After the java projects are imported, you can switch open debug panel, choose `Attach to prestissimo` or `Attach to presto` to start debugging

~~Note: if you are using vscodium based IDE, please use https://cypherpunksamurai.github.io/vsix-downloader-webui/ to download extension and install~~

Vscodium based IDE seems can not use the Remote Development plugin, seems we have to use vscode to dev inside the container
