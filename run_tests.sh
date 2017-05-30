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
/usr/local/tomcat/${OPENGROKVERSION}/bin/OpenGrok deploy \
    && /usr/local/tomcat/${OPENGROKVERSION}/bin/OpenGrok index $(dirname $SRCDIR) \
    && sudo service cron start \
    && catalina.sh start
sleep 30
curl -f http://localhost:8080/source/xref/$(basename $SRCDIR)/
