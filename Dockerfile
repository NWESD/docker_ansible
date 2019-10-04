FROM debian:buster

LABEL maintainer="zoredache@gmail.com"

RUN apt-get update \
 && </dev/null DEBIAN_FRONTEND=noninteractive \
    apt-get --yes install  --no-install-recommends \
        gawk procps openssh-client git build-essential krb5-user libkrb5-dev lsb-release \
        python3-dev python3-netaddr python3-pip python3-setuptools python3-wheel \
        python3-passlib rsync wget unzip \
        sshpass etckeeper sudo \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN </dev/null adduser --quiet --disabled-password --gecos '' --uid 1000 ansible \
 && </dev/null adduser --quiet ansible sudo

RUN  wget -nv -O /tmp/bw-linux.zip \
     https://github.com/bitwarden/cli/releases/download/v1.7.4/bw-linux-1.7.4.zip \
  && echo "65cc78775e2639d19c81066b6a9536c8c6cba258a0a3dd04f51729f265dd9bc3  /tmp/bw-linux.zip" | \
     sha256sum --check \
  && cd /usr/local/bin \
  && unzip /tmp/bw-linux.zip bw \
  && chmod 0775 /usr/local/bin/bw \
  && rm /tmp/bw-linux.zip

COPY ./ansible /etc/ansible
RUN pip3 install --requirement /etc/ansible/requirements.txt \
 && rm -r ~/.cache/pip/ \
 && mkdir /project

WORKDIR /project

# until this is fixed https://github.com/fboender/ansible-cmdb/issues/189
COPY ./misc/ansible-cmdb /usr/local/bin/ansible-cmdb

USER 1000
CMD ["/usr/local/bin/ansible-playbook","--version"]
