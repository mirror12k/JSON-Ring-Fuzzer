FROM ubuntu:22.04

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update && apt-get install -y \
    software-properties-common

## Install Oracle's JDK
# add oracle jdk repository
RUN add-apt-repository ppa:ts.sch.gr/ppa \
  && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
  && apt update \
  && apt install -y oracle-java8-installer \
  && apt install -y oracle-java8-set-default
# install stuff
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y make perl cpanminus php gcc nodejs git mono-mcs bsdmainutils \
  && cpanm -v --notest JSON::PP JSON::XS List::Util

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

WORKDIR /work

CMD ["/bin/bash"]

