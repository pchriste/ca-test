FROM registry.access.redhat.com/rhel-atomic
MAINTAINER abhijit.bhadra@ca.com


### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="ca/umagent" \
      vendor="CA Inc" \
      version="1.0" \
      release="1" \
      summary="CA Inc's Monitoring app for Openshift" \
      description="Monitoring app will do ....." \
### Required labels above - recommended below
      url="https://www.ca.com" \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description="Monitor app will do ....." \
      io.k8s.display-name="Monitor app" \
      io.openshift.expose-services="" \
      io.openshift.tags="ca,monitor"


### Atomic Help File - Write in Markdown, it will be converted to man format at build time.
### https://github.com/projectatomic/container-best-practices/blob/master/creating/help.adoc
COPY help.md /tmp/

### add licenses to this directory
COPY licenses /licenses

### Add necessary Red Hat repos and install packages here
RUN    microdnf --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-optional-rpms --enablerepo=rhel-7-server-extras-rpms \ 
       install --nodocs golang-github-cpuguy83-go-md2man cronie  && \

### help file markdown to man conversion
    go-md2man -in /tmp/help.md -out /help.1 && \
    microdnf update; microdnf clean all

### Setup user for build execution and application runtime
#---> where I left off, make this the docker dir? #ENV APP_ROOT=/opt/app-root \
#    USER_NAME=default \
#    USER_UID=10001
#ENV APP_HOME=${APP_ROOT}/src  PATH=$PATH:${APP_ROOT}/bin
#RUN mkdir -p ${APP_HOME}
#COPY bin/ ${APP_ROOT}/bin/
#RUN chmod -R u+x ${APP_ROOT}/bin && \
#    useradd -l -u ${USER_UID} -r -g 0 -d ${APP_ROOT} -s /sbin/nologin -c "${USER_NAME} user" ${USER_NAME} && \
#    chown -R ${USER_UID}:0 ${APP_ROOT} && \
#    chmod -R g=u ${APP_ROOT}
#####

RUN mkdir -p /usr/local/openshift/umagent
#RUN cp ./docker/docker /usr/bin/
ADD ./OpenshiftMonitor.tar.gz /usr/local/openshift/umagent
ADD ./run.sh /usr/local/openshift/umagent
RUN chmod +x /usr/local/openshift/umagent/run.sh
WORKDIR /usr/local/openshift/umagent
CMD ["bash","run.sh"]
#########



####### Add app-specific needs below. #######
### Containers should NOT run as root as a good practice
USER 10001
#WORKDIR ${APP_ROOT}
#VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data
#CMD run
CMD ["bash","run.sh"]
