#!/bin/sh
SRCDIR=/usr/local/tomcat/test-data
mkdir $SRCDIR \
  && cd $SRCDIR \
  && git init \
  && cat <<END > main.c
#include <stdio.h>
int main(int argc, char** argv) {
    printf("Hello\n");
}
END
git add main.c \
  && git commit -m"Test source"
opengrok-*/bin/OpenGrok deploy \
    && opengrok-*/bin/OpenGrok index $SRCDIR \
    && sudo service cron start \
    && catalina.sh run
curl -f http://localhost:8080/source/xref/$(basename $SRCDIR)
