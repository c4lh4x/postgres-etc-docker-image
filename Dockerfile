FROM alpine:3.15.5
EXPOSE 5432

# installs
RUN apk update &&\
\
apk add build-base wget git sudo postgresql14 postgresql14-dev postgresql-contrib postgis &&\
\
mkdir -p /var/lib/postgres/data &&\
mkdir -p /var/lib/postgresql/plugins &&\
chmod 0755 -R /var/lib/postgresql/* &&\
chown postgres:postgres -R /var/lib/postgresql/*  &&\
\
mkdir /mutations &&\
chmod 0755 /mutations &&\
chown postgres:postgres /mutations &&\
\
mkdir /configs &&\
chmod 0755 /configs &&\
chown postgres:postgres -R /configs &&\
\
echo 'postgres ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

COPY scripts/* /usr/local/bin/
RUN chmod +x -R /usr/local/bin/*.sh

ENTRYPOINT [ "/bin/sh", "/usr/local/bin/00_init.sh" ]
