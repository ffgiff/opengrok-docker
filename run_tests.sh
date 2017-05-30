#!/bin/sh
SRCDIR=/data/src
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
/usr/local/tomcat/opengrok-*/bin/OpenGrok index /data
curl -f http://localhost:8080/source/xref/src
