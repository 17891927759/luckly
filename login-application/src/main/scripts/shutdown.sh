#!/bin/bash -
#===============================================================================
#
#          FILE: startup.sh
#
#         USAGE: ./startup.sh
#
#   DESCRIPTION: springboot jar 启动脚本
#
#       OPTIONS: springboot 系统环境变量：APP_NAME
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Roc Wong (https://roc-wong.github.io), float.wong@icloud.com
#  ORGANIZATION: 中泰证券
#       CREATED: 04/19/2019 02:21:48 PM
#      REVISION:  ---
#===============================================================================

# set -o nounset                              # Treat unset variables as an error

SERVICE_NAME=login-application

if [[ -z "$JAVA_HOME" && -d /usr/java/latest/ ]]; then
    export JAVA_HOME=/usr/java/latest/
fi

cd `dirname $0`/..

if [[ ! -f ${SERVICE_NAME}".jar" && -d current ]]; then
    cd current
fi

if [[ -f ${SERVICE_NAME}".jar" ]]; then
  chmod a+x ${SERVICE_NAME}".jar"
  ./${SERVICE_NAME}".jar" stop
  # service ${SERVICE_NAME} stop
fi
