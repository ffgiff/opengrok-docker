# Dockerfile for OpenGrok
FROM tomcat:8.5-jre8-alpine

# Name of OpenGrok zip file.
ENV OPENGROKVERSIONCODE 1.2.23
ENV OPENGROKVERSION opengrok-${OPENGROKVERSIONCODE}
ENV OPENGROKZIP https://github.com/oracle/OpenGrok/releases/download/${OPENGROKVERSIONCODE}/${OPENGROKVERSION}.tar.gz

# Environment needed to deploy opengrok
ENV OPENGROK_APP_SERVER=Tomcat
ENV OPENGROK_WAR_TARGET_TOMCAT=$CATALINA_HOME/webapps
ENV OPENGROK_TOMCAT_BASE=$CATALINA_HOME

RUN apk update \
    && apk add \
        curl \
        dcron \
        git \
        jansson \
        libxml2 \
        sudo \
        yaml \
    && apk --no-cache --virtual build-deps add \
        autoconf \
        automake \
        gcc \
        jansson-dev \
        libxml2-dev \
        make \
        musl-dev \
        yaml-dev \
    && git clone http://github.com/universal-ctags/ctags.git \
    && cd ctags \
    && ./autogen.sh \
    && ./configure \
    && make && make install \
    && cd - && rm -rf ctags \
    && apk del build-deps \
    && curl -LO "${OPENGROKZIP}" \
    && tar xzf ${OPENGROKVERSION}.tar.gz \
    && adduser -D tomcat \
    && echo "tomcat:builder" | chpasswd \
    && echo "00 10 * * 1-5 java -jar ${OPENGROKVERSION}/lib/opengrok.jar -d /var/opengrok/data -G -H -P -S -s /data -W /var/opengrok/etc/configuration.xml" >> crontab \
    && crontab -u tomcat crontab \
    && echo "tomcat ALL=NOPASSWD: /usr/sbin/crond" >> /etc/sudoers.d/cron \
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
    && sudo crond \
    && catalina.sh run

