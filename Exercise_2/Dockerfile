FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    python3 \
    python3-pip \
    sed

RUN pip3 install awscli

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_linux_amd64.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin/ \
    && rm /tmp/terraform.zip

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
    | tar xz -C /tmp && mv /tmp/eksctl /usr/local/bin

WORKDIR /terraform

COPY . /terraform

ENTRYPOINT ["/bin/bash"]
