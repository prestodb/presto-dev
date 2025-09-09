# Presto Docker development environment

* https://hub.docker.com/r/unidevel/presto-dev

## Prerequisites

* Docker or Podman must be installed and running.

## Quick start

This environment can be run on both Linux and macOS.

Run the following command to clone the `presto-dev` repository into your local `presto` directory and start the development environment.

```sh
# Inside your local presto directory
git clone https://github.com/unidevel/presto-dev.git

# Start the docker container
cd presto-dev
make start

# Enter shell
make shell
```

When a new `presto-dev` image is published, run the following command to pull the latest version.

```sh
# Under presto-dev, run this to pull the latest presto-dev image
make pull
```

## Start Presto & Prestissimo server

Run `make shell` in the presto-dev directory to open a new container shell. 

All the commands below must be executed inside the container shell. 

```sh
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

Use http://localhost:8080 to open the Presto console.

## Update Presto or Prestissimo configuration

The configuration files are in the [presto/etc](https://github.com/unidevel/presto-dev/tree/main/presto/etc) and [prestissimo/etc](https://github.com/unidevel/presto-dev/tree/main/prestissimo/etc) directories.

In the container, they are mounted as `/opt/presto/etc` and `/opt/prestissimo/etc` respectively.

You can add more catalogs or update the configuration files.

The [presto/data](https://github.com/unidevel/presto-dev/tree/main/presto/data) is mounted as `/opt/presto/data`.

In this way, you can update and keep them locally in case the container is deleted.

## Dev with dev container(VSCode)

1. Install [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension.
2. Open `Remote Explorer` panel, switch to `Dev Containers` from the drop down widget on the top.
3. Open the `/presto` directory in the composed container `presto-dev` (If importing Maven projects takes a long time, run `./mvnw clean` in the `/presto` directory and `make clean` in the `/presto/presto-native-execution` directory inside the container.).
4. If `presto/.vscode/launch.json` is not already configured, the file [launch.json](https://github.com/unidevel/presto-dev/tree/main/launch.json) is copied there automatically. If it is already configured, append the contents of [launch.json](https://github.com/unidevel/presto-dev/tree/main/launch.json) from this repository to your existing `presto/.vscode/launch.json`.
5. Install Microsoft [Extension Pack for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) and [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack) in the container.
6. Start Presto & Prestissimo in the container.
7. After the Java projects are imported, open the Debug panel and select either `Attach to Prestissimo` or `Attach to Presto` to start debugging.

## Dev with ssh

VSCodium based IDEs cannot use the Remote Development extension. If your IDE supports remote ssh extension, you can try this:

1. Make sure you have generated ssh keys and updated the `authorized_keys` file in your local machine.
2. Use `make start` to start the container. This will copy your SSH keys from `~/.ssh/authorized_keys` to the `root/.ssh` directory inside `presto-dev`.
3. Add the following entry to your local `~/.ssh/config` file:
```
Host presto-dev
  HostName localhost
  Port 2222
  User root
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```
4. Test the ssh connection with `ssh presto-dev`.
5. Connect to the `presto-dev` SSH server using your IDE.

## Keep your data

By default, the `root` directory in this repo will be mounted to `/root` in the container. Use this `root` directory to share your data between your local machine and the container.

To keep `ccache`, `m2`, and other cache files locally, run the following commands after starting the shell for the first time. This will copy the cache files into your local root folder.

```sh
ls -la /root

rm -f /root/.ccache
cp -a /opt/cache/.ccache /root/.ccache

rm -f /root/.m2
cp -a /opt/cache/.m2 /root/.m2

rm -f /root/.cache
cp -a /opt/cache/.cache /root/.cache
```

