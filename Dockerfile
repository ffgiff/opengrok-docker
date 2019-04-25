# Dockerfile for OpenGrok
FROM tomcat:8.5-jre8

# Name of OpenGrok zip file.
ENV OPENGROKVERSIONCODE 1.2.7
ENV OPENGROKVERSION opengrok-${OPENGROKVERSIONCODE}
ENV OPENGROKZIP https://github.com/oracle/OpenGrok/releases/download/${OPENGROKVERSIONCODE}/${OPENGROKVERSION}.tar.gz

# Environment needed to deploy opengrok
ENV OPENGROK_APP_SERVER=Tomcat
ENV OPENGROK_WAR_TARGET_TOMCAT=$CATALINA_HOME/webapps
ENV OPENGROK_TOMCAT_BASE=$CATALINA_HOME

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cron \
        git \
        libjansson4 \
        sudo \
        libyaml-0-2 \
        autoconf \
        automake \
        gcc \
        libjansson-dev \
        libxml2-dev \
        libyaml-dev \
        make \
        pkg-config \
    && git clone http://github.com/universal-ctags/ctags.git \
    && cd ctags \
    && ./autogen.sh \
    && ./configure \
    && make && make install \
    && cd - && rm -rf ctags \
    && apt-get purge -y \
        autoconf \
        automake \
        gcc \
        libjansson-dev \
        libxml2-dev \
        libyaml-dev \
        make \
        pkg-config \
    && curl -LO "${OPENGROKZIP}" \
    && tar xaf ${OPENGROKVERSION}.tar.gz \
    && useradd -m tomcat \
    && echo "tomcat:builder" | chpasswd \
    && echo "00 10 * * 1-5 java -jar ${OPENGROKVERSION}/lib/opengrok.jar -d /var/opengrok/data -G -H -P -S -s /data -W /var/opengrok/etc/configuration.xml" >> crontab \
    && crontab -u tomcat crontab \
    && echo "tomcat ALL=NOPASSWD: /usr/sbin/service cron start" >> /etc/sudoers.d/cron \
    && mkdir -p /var/opengrok/data \
    && mkdir -p /var/opengrok/etc \
    && chown -R tomcat /var/opengrok \
    && chown -R tomcat . \
    && echo done

COPY run_tests.sh /usr/local/tomcat/
VOLUME /data
USER tomcat
CMD cp ${OPENGROKVERSION}/lib/source.war webapps/${OPENGROK_WEBAPP_CONTEXT:-source}.war \
    && java -jar ${OPENGROKVERSION}/lib/opengrok.jar \
        -d /var/opengrok/data \
        -G -H -P -S \
        -s /data \
        -W /var/opengrok/etc/configuration.xml \
    && sudo service cron start \
    && catalina.sh run

