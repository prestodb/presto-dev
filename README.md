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
ls -la /root

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

## Dev with dev container(VSCode)

1. Install [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension
2. Open `Remote Explorer` panel, switch to `Dev Containers` from the dropdown widget on the top
3. Open the `/presto` directory in the composed container `presto-dev` (Make sure clean your local presto project, otherwist it will take a long time to import maven projects)
4. Install microsoft `Extension Pack for Java` and `C/C++ Extension Pack`
4. Start presto & prestissimo in the container
5. After the java projects are imported, you can switch open debug panel, choose `Attach to prestissimo` or `Attach to presto` to start debugging

## Dev with ssh(will publish new image later)

Vscodium based IDEs can not use the Remote Development extension, if your IDE supports remote ssh extension, you can try this:

1. Make sure you have generated ssh keys and updated the `authorized_keys` file in your local machine
2. Use `make start` to start the container, it will copy the ssh keys to the root/.ssh directory
3. Update your local ~/.ssh/config file with the following content:
```
Host presto-dev
  HostName localhost
  Port 2222
  User root
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```
4. Test the ssh connection with `ssh presto-dev`
5. Start vscode in the container, if everything is ok, run `ls -la /root` to see what files are in your root directory
6. Connect to the ssh server `presto-dev` with your IDE

## Keep your data

By default, the `root` directory in the this repo will be mounted to `/root` in the container as home directory, you can share your data between your local machine and the container.

If you want to keep ccache/m2/cache locally, after start the shell for the first time, run the commands below

```
ls -la /root

rm -f /root/.ccache
cp -a /opt/cache/.ccache /root/.ccache

rm -f /root/.m2
cp -a /opt/cache/.m2 /root/.m2

rm -f /root/.cache
cp -a /opt/cache/.cache /root/.cache
```