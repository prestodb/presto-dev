# Presto/Prestissimo Dev Container

With this dev container, you can:
* Build Presto and Prestissimo from source
* Run Presto and Prestissimo with different configurations
* Debugging with VS Code or any IDE with ssh support
* Working on UI development
* Develop unit tests with test containers

## Prerequisites

* Docker or Podman must be installed and running.

## Quick start

This environment can be run on both Linux and macOS.

Run the following command to clone the `presto-dev` repository into your local `presto` directory, start the dev container and enter the container shell.

```sh
# Inside your local presto directory
git clone https://github.com/prestodb/presto-dev.git

# Start the dev container and enter container shell
cd presto-dev
make
```

In the dev container shell, you can run the following commands to work with source code.

```sh
# Build presto (.m2 already cached)
cd /presto
./mvnw clean install -DskipTests

# Run unit tests with test container
start-podman
cd /presto
./mvnw test -pl presto-main -Dtest="com/facebook/presto/server/security/oauth2/**"

# Build prestissimo(make debug or make release)
cd /presto/presto-native-execution
make

# Start presto-ui development server, open http://localhost:8081 in your browser
# Run "start-cluster <cluster profile>" first to start a presto cluster
cd /presto/presto-ui/src
yarn install
yarn serve
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

The [presto/data](./presto/data) is mounted as `/opt/presto/data` to persist data between container restarts.

This approach allows you to maintain multiple configuration profiles and easily switch between them using the `start-cluster` script.

## Dev with dev container(VSCode)

1. Install [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) extension.
2. Open `Remote Explorer` panel, switch to `Dev Containers` from the drop down widget on the top.
3. Open the `/presto` directory in the composed container `presto-dev` (If importing Maven projects takes a long time, run `./mvnw clean` in the `/presto` directory and `make clean` in the `/presto/presto-native-execution` directory inside the container.).
4. If `presto/.vscode/launch.json` is not already configured, the file [launch.json](./launch.json) is copied there automatically. If it is already configured, append the contents of [launch.json](./launch.json) from this repository to your existing `presto/.vscode/launch.json`.
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

#### Available Scripts

- **build-and-install**: Builds Presto and Prestissimo from source and installs them into `/opt/presto` and `/opt/prestissimo` respectively.

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

### 2. Podman Container Scripts

The development environment includes scripts to manage Podman containers for testing. Currently it only supports centos based dev container.

#### Available Scripts

- **start-podman**: Starts rootful podman with sock file `unix:///var/run/docker.sock` to enable running test containers inside the dev container.
- **stop-podman**: Stops the podman service.

#### Usage

```sh
# Start podman service
start-podman

# Run your tests that use test containers
cd /presto
./mvnw test -pl presto-main -Dtest="com/facebook/presto/server/security/oauth2/**"

# Stop podman service when done
stop-podman
```

The `start-podman` script enables running test containers inside the dev container by providing a Docker-compatible socket at `unix:///var/run/docker.sock`. This allows test frameworks like TestContainers to work properly within the development environment.

### 3. Cluster Management Scripts

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
- **router**: Starts a Presto router and a single node Presto server

The logs for Presto servers are available at `/opt/presto/data/var/log/server.log`, the logs for Prestissimo servers are available at `/opt/prestissimo/logs/server.log`, and the logs for Presto router are available at `/opt/router/logs/server.log`.

## Build your own images

You can build your own images by forking this repository and update [.env](./.env) file to customize your build.

For example, if you want to push the images to your own docker registry, you can add the following lines to [.env](./.env) file:

```
ORG = <your github org>
DOCKERHUB = <docker.io, ghcr.io or other registries>
```

If you want to customize the compiling options like cmake flags or parallel build options, you can also update the [.env](./.env) file:

```
NUM_THREADS=<number of threads for compiling>
COMMON_CMAKE_FLAGS=<common shared cmake flags>
CENTOS_CMAKE_FLAGS=<centos specific cmake flags>
UBUNTU_CMAKE_FLAGS=<ubuntu specific cmake flags>
```

In this way, you can build your own images and customize them according to your needs.

To build and push the images, you can use the following commands under directory  `presto-dev`:

```sh
# Build centos images
make centos-cpp-dev && make centos-java-dev && make centos-dev

# Build ubuntu images
make ubuntu-cpp-dev && make ubuntu-java-dev && make ubuntu-dev

# Re-tag images for publishing
make release-prepare

# Publish images
make release-publish
```