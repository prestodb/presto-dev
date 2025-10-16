# Presto/Prestissimo Dev Container

* https://hub.docker.com/r/unidevel/presto-dev

## Prerequisites

* Docker or Podman must be installed and running.

## Quick start

This environment can be run on both Linux and macOS.

Run the following command to clone the `presto-dev` repository into your local `presto` directory and start the development environment.

```sh
# Inside your local presto directory
git clone https://github.com/unidevel/presto-dev.git

# Start the dev container and enter shell
cd presto-dev
make
```

When a new `presto-dev` image is published, run the following command to pull the latest version.

```sh
# Under presto-dev, run this to pull the latest presto-dev image
make pull
```

## Start Presto & Prestissimo server

Run `make` or `make shell` in the presto-dev directory to open a new container shell.

All the commands below must be executed inside the container shell.

```sh
ls -la /root

# Start presto coordinator and prestissimo worker
start-cluster default

# Start presto single node and prestissimo sidecar
start-cluster sidecar

# Stop cluster
stop-cluster

# Build presto (.m2 already cached)
cd /presto
./mvnw clean install -DskipTests

# Build prestissimo(make debug or make release)
cd /presto/presto-native-execution
make
```

Use http://localhost:8080 to open the Presto console.

## Update Presto or Prestissimo configuration

The configuration files are organized within cluster profiles in the `clusters/` directory. Each cluster profile contains its own configuration files for Presto coordinator, Presto worker, and/or Prestissimo worker.

Available cluster profiles:
- `presto`: Presto coordinator and worker
- `prestissimo`: Presto coordinator and Prestissimo worker
- `presto-single`: Single node Presto server
- `sidecar`: Presto coordinator with worker and Prestissimo worker with sidecar configuration

You can modify the existing configuration files in these profiles or create a new cluster profile based on your specific requirements. To create a new cluster profile:

1. Create a new directory under `clusters/` with your profile name
2. Copy the configuration files from an existing profile
3. Modify the configuration files as needed
4. Create a `start-cluster` script for your profile

The [presto/data](https://github.com/unidevel/presto-dev/tree/main/presto/data) is mounted as `/opt/presto/data` to persist data between container restarts.

This approach allows you to maintain multiple configuration profiles and easily switch between them using the `start-cluster` script.

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

By default, the `.ccache`, `.m2`, and `.cache` directories under `/root` directory are symbolic links to the image's `/opt/cache` directories. These symbolic links will disappear when the container is shut down. To preserve your cache data between container restarts, you need to replace these symbolic links with local directories in the mounted `/root` directory.

Run the following command in the shell of dev container:

```sh
use-local-cache
```

This script replaces the symbolic links with actual directories in your local `/root` folder, copying the cache data from `/opt/cache`. Since the `root` directory is mounted into the container, these cache files will be preserved even when the container is removed, significantly improving build performance on subsequent runs.

## Development Scripts

The development environment includes scripts to help with building and installing Presto and Prestissimo.

### 1. Building and installing script

**build-and-install**: Builds Presto and Prestissimo from source and installs them into `/opt/presto` and `/opt/prestissimo` respectively.

#### Usage

```sh
build-and-install
```

This script:
1. Builds Presto from source in `/presto`
2. Builds Prestissimo from source in `/presto/presto-native-execution`
3. Installs the built binaries to `/opt/presto` and `/opt/prestissimo`
4. Makes the newly built versions available for use

After running this script, you can start the servers with the newly built versions using the cluster management scripts.

### 2. Cluster Management Scripts

The development environment includes scripts to easily start and stop Presto and Prestissimo clusters. These scripts are located in the `/root/bin` directory.

#### Available Scripts

- **start-cluster**: Starts a specific cluster profile (presto, prestissimo, presto-single, or sidecar)
- **stop-cluster**: Stops all running Presto and Prestissimo servers across all cluster profiles

#### Usage

##### Starting a Cluster

```sh
start-cluster <cluster-profile>
```

Where `<cluster-profile>` is one of the available cluster profiles in the `/opt/clusters` directory (e.g., presto, prestissimo, presto-single, sidecar).

Example:
```sh
# Start the presto-single cluster
start-cluster presto-single

# Start the prestissimo cluster
start-cluster prestissimo
```

##### Stopping All Clusters

```sh
stop-cluster
```

This command will stop all running Presto and Prestissimo servers across all cluster profiles.

#### Cluster Profiles

Each cluster profile has its own configuration and behavior:

- **presto**: Starts a Presto coordinator and a Presto worker
- **prestissimo**: Starts a Presto coordinator and a Prestissimo worker
- **presto-single**: Starts a single node Presto server (coordinator with worker)
- **sidecar**: Starts a single node Presto coordinator with worker and a Prestissimo worker with sidecar configuration

The logs for Presto servers are available at `/opt/presto/data/var/log/server.log`, and the logs for Prestissimo servers are available at `/opt/prestissimo/logs/server.log`.
