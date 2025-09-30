FROM registry.fedoraproject.org/fedora-minimal:latest
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN dnf -y install mongodb-org-tools && dnf clean all
COPY backup.sh /backup.sh
ENTRYPOINT ["/bin/bash", "-c", "/backup.sh"]
