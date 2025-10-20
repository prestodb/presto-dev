export LANG=C.UTF-8
export CXX=/opt/rh/gcc-toolset-12/root/bin/g++
export CC=/opt/rh/gcc-toolset-12/root/bin/gcc
if [ -d /usr/lib/jvm/jre-17-openjdk ]; then
  export JAVA_HOME=/usr/lib/jvm/jre-17-openjdk
fi
export JMX_PROMETHEUS_JAVAAGENT_VERSION=0.20.0
export PRESTO_HOME=/opt/presto
export PRESTISSIMO_HOME=/opt/prestissimo
export BUILD_BASE_DIR=_build

source /etc/os-release
source /root/.build-env

if [ "$ID" == "centos" ]; then
  export EXTRA_CMAKE_FLAGS="$CENTOS_CMAKE_FLAGS $COMMON_CMAKE_FLAGS"
else
  export EXTRA_CMAKE_FLAGS="$UBUNTU_CMAKE_FLAGS $COMMON_CMAKE_FLAGS"
fi
export PATH=/root/bin:/root/.local/bin:$PATH

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

