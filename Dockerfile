FROM ubuntu:latest
LABEL Description="Ubuntu server with Nexus"

RUN apt-get update && \
apt-get install openjdk-8-jdk -y

ARG dest=/usr/app
RUN mkdir $dest
RUN useradd -d /opt/nexus -s /bin/bash nexus
COPY ./nexus-3.41.1-01-unix.tar.gz $dest
WORKDIR $dest
RUN tar xzf nexus-3.41.1-01-unix.tar.gz

RUN mv nexus-3.41.1-01 /opt/nexus
RUN mv sonatype-work /opt/

RUN sed -i 's/run_as_user=""/run_as_user="nexus"/g' /opt/nexus/bin/nexus.rc
RUN sed -i 's/-Xms2703m/-Xms1024m/g' /opt/nexus/bin/nexus.vmoptions
RUN sed -i 's/-Xmx2703m/-Xmx1024m/g' /opt/nexus/bin/nexus.vmoptions
RUN sed -i 's/-XX:MaxDirectMemorySize=2703m/-XX:MaxDirectMemorySize=1024m/g' /opt/nexus/bin/nexus.vmoptions

RUN mkdir /opt/sonatype-work/nexus3/etc/
RUN echo "application-host=0.0.0.0" >> /opt/sonatype-work/nexus3/etc/nexus.properties

RUN chown -R nexus:nexus /opt/nexus /opt/sonatype-work

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf $dest/nexus-3.41.1-01-unix.tar.gz

EXPOSE 8081

COPY ./entry-point.sh $dest
RUN chmod +x ./entry-point.sh

ENTRYPOINT ["./entry-point.sh"]
