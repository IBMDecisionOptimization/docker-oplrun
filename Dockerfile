# Dockerfile to install COS into a container and then remove everything
# but the oplrun runtime environment

FROM ubuntu:latest
MAINTAINER daniel.junglas@de.ibm.com

# Installation directory. This is also specified in installer.properties
ARG COSDIR=/opt/COS

# Copy installer and installer arguments from local disk
COPY cos_installer-*.bin /tmp/installer
COPY install.properties /tmp/install.properties
RUN chmod u+x /tmp/installer

# Install Java runtime. This is required by the installer.
# It is also required in case the .mod file uses external Java
RUN apt-get update && apt-get install -y default-jre

# Install COS
RUN /tmp/installer -f /tmp/install.properties

# Remove installer, temporary files, and everything we don't need for oplrun
RUN rm -f /tmp/installer /tmp/install.properties
RUN rm -rf ${COSDIR}/concert \
    ${COSDIR}/cpoptimizer \
    ${COSDIR}/doc \
    ${COSDIR}/python \
    ${COSDIR}/README \
    ${COSDIR}/opl/ant \
    ${COSDIR}/opl/examples \
    ${COSDIR}/opl/include \
    ${COSDIR}/opl/lib \
    ${COSDIR}/opl/oplide

# Remove the CPLEX directory piecemeal. In case we are installing a
# community edition, we don't want to remove the cpxchecklic binary
RUN rm -rf \
    ${COSDIR}/cplex/examples \
    ${COSDIR}/cplex/include \
    ${COSDIR}/cplex/lib \
    ${COSDIR}/cplex/matlab \
    ${COSDIR}/cplex/python \
    ${COSDIR}/cplex/readmeUNIX.html \
    ${COSDIR}/cplex/bin/x86-64_linux/*.so \
    ${COSDIR}/cplex/bin/x86-64_linux/cplex* \
    ${COSDIR}/cplex/bin/x86-64_linux/cpxworker

# Setup environment so that binaries and libraries are on the path
ENV PATH ${PATH}:${COSDIR}/opl/bin/x86-64_linux
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${COSDIR}/opl/bin/x86-64_linux
# This is for the community edition only
ENV PATH ${PATH}:${COSDIR}/cplex/bin/x86-64_linux

# Default user is cplex
RUN adduser --disabled-password --gecos "" cplex 
USER cplex
WORKDIR /home/cplex

CMD /bin/bash
