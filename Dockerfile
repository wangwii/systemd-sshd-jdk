FROM centos/systemd:latest
LABEL maintainer "Wang Wei - https://github.com/wangwii"

# Install sshd service
RUN yum -y update && \
    yum -y install openssh openssh-clients openssh-server
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa && \
    ssh-keygen -A
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

COPY .ssh/ /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa
RUN echo 'root:root' | chpasswd
RUN systemctl enable sshd.service

# Install Java
ENV JAVA_VERSION=8 \
    JAVA_UPDATE=161 \
    JAVA_BUILD=12 \
    JAVA_PATH=2f38c3b165be4555a1fa6e98c45e0808
RUN curl -kL -H "Cookie: oraclelicense=accept-securebackup-cookie" \
        -o "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.rpm" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.rpm" && \
    rpm -ivh "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.rpm"

# Cleanup
RUN yum clean all && \
    rm -rf /var/cache/yum "$JAVA_HOME/"*src.zip "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.rpm"

ENV JAVA_HOME="/usr/java/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}"
ENV PATH=$JAVA_HOME/bin:$PATH
