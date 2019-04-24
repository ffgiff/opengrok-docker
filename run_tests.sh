#!/bin/sh
SRCDIR=/usr/local/tomcat/test-data/test-repo
mkdir -p $SRCDIR \
  && cd $SRCDIR \
  && git init \
  && cat <<END > main.c
#include <stdio.h>
int main(int argc, char** argv) {
    printf("Hello\n");
}
END
git config --global user.email "test@localhost" \
  && git config --global user.name "Test" \
  && git add main.c \
  && git commit -m"Test source"
cd /usr/local/tomcat
    && java -jar ${OPENGROKVERSION}/lib/opengrok.jar \
	    -d /var/opengrok/data \
	    -G -H -P -S \
	    -s $(dirname $SRCDIR) \
	    -W /var/opengrok/etc/configuration.xml \
    && catalina.sh start
sleep 30
curl -f http://localhost:8080/source/xref/$(basename $SRCDIR)/
