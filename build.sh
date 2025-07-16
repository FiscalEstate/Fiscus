#!/bin/bash

export ANT_OPTS='-XX:PermSize=64m -XX:MaxPermSize=128m -Xmx8704m -Dinfo.aduna.platform.appdata.basedir=./webapps/openrdf-sesame/app_dir/ -Dorg.eclipse.jetty.LEVEL=OFF -Dorg.eclipse.jetty.servlet.LEVEL=WARN'

sw/ant/bin/ant -S -f local.build.xml $*
