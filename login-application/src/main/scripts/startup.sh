#!/bin/bash -
#===============================================================================
#
#          FILE: startup.sh
#
#         USAGE: ./startup.sh
#
#   DESCRIPTION: springboot jar 启动脚本
#
#       OPTIONS: springboot executable jar 依赖系统环境变量：APP_NAME
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

LOG_DIR=/data/logCenter
SERVER_PORT=8080
CONTEXT_PATH=

#export JAVA_OPTS="-Xms2560m -Xmx2560m -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=384m -XX:NewSize=1536m -XX:MaxNewSize=1536m -XX:SurvivorRatio=8"

#export JAVA_OPTS="$JAVA_OPTS -server -XX:-ReduceInitialCardMarks"

export JAVA_OPTS="$JAVA_OPTS -XX:+UseParNewGC -XX:ParallelGCThreads=4 -XX:MaxTenuringThreshold=9 -XX:+UseConcMarkSweepGC -XX:+DisableExplicitGC -XX:+UseCMSInitiatingOccupancyOnly -XX:+ScavengeBeforeFullGC -XX:+UseCMSCompactAtFullCollection -XX:+CMSParallelRemarkEnabled -XX:CMSFullGCsBeforeCompaction=9 -XX:CMSInitiatingOccupancyFraction=60 -XX:+CMSClassUnloadingEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSPermGenSweepingEnabled -XX:CMSInitiatingPermOccupancyFraction=70 -XX:+ExplicitGCInvokesConcurrent -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC -XX:+UseGCLogFileRotation -XX:+HeapDumpOnOutOfMemoryError -XX:-OmitStackTraceInFastThrow -Duser.timezone=Asia/Shanghai -Dclient.encoding.override=UTF-8 -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom"

export JAVA_OPTS="$JAVA_OPTS -Xloggc:$LOG_DIR/gc.log -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=5M -XX:HeapDumpPath=$LOG_DIR/HeapDumpOnOutOfMemoryError/"


PATH_TO_JAR=${SERVICE_NAME}".jar"

SERVER_URL="http://localhost:${SERVER_PORT}/${CONTEXT_PATH}"


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  checkPidAlive
#   DESCRIPTION:  检查springboot进程是否启动成功，默认进程路径 /var/run/${APP_NAME}/${SERVICE_NAME}.pid
#    PARAMETERS:
#       RETURNS:
#-------------------------------------------------------------------------------
function checkPidAlive() {
    for i in `ls -t /var/run/${SERVICE_NAME}*/*.pid 2>/dev/null`
    do
        read pid < $i

        result=$(ps -p "$pid")
        if [[ "$?" -eq 0 ]]; then
            return 0
        else
            printf "\npid - $pid just quit unexpectedly, please check logs under $LOG_DIR and /tmp for more information!\n"
            exit 1;
        fi
    done

    printf "\nNo pid file found, startup may failed. Please check logs under $LOG_DIR and /tmp for more information!\n"
    exit 1;
}

if [[ "$(uname)" == "Darwin" ]]; then
    windows="0"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    windows="0"
elif [[ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]]; then
    windows="1"
else
    windows="0"
fi

# for Windows
if [[ "$windows" == "1" ]] && [[ -n "${JAVA_HOME}" ]] && [[ -x "${JAVA_HOME}/bin/java" ]]; then
    tmp_java_home=`cygpath -sw "${JAVA_HOME}"`
    export JAVA_HOME=`cygpath -u ${tmp_java_home}`
    echo "Windows new JAVA_HOME is: ${JAVA_HOME}"
fi

cd `dirname $0`/..

for i in `ls ${SERVICE_NAME}-*.jar 2>/dev/null`
do
    if [[ ! $i == *"-sources.jar" ]]
    then
        PATH_TO_JAR=$i
        break
    fi
done

if [[ ! -f PATH_TO_JAR && -d current ]]; then
    cd current
    for i in `ls ${SERVICE_NAME}-*.jar 2>/dev/null`
    do
        if [[ ! $i == *"-sources.jar" ]]
        then
            PATH_TO_JAR=$i
            break
        fi
    done
fi

if [[ -f ${SERVICE_NAME}".jar" ]]; then
  rm -rf ${SERVICE_NAME}".jar"
fi

printf "$(date) ==== Starting ==== \n"

ln ${PATH_TO_JAR} ${SERVICE_NAME}".jar"

#ln -s `pwd`/${SERVICE_NAME}".jar" /etc/init.d/${SERVICE_NAME}

chmod a+x ${SERVICE_NAME}".jar"
./${SERVICE_NAME}".jar" start
#service ${SERVICE_NAME} start

rc=$?;

if [[ $rc != 0 ]];
then
    echo "$(date) Failed to start ${SERVICE_NAME}.jar, return code: $rc"
    exit $rc;
fi

declare -i counter=0
declare -i max_counter=24 # 24*5=120s
declare -i total_time=0

printf "Waiting for server startup"
until [[ (( counter -ge max_counter )) || "$(curl -X GET --silent --connect-timeout 1 --max-time 2 --head $SERVER_URL | grep "HTTP")" != "" ]];
do
    printf "."
    counter+=1
    sleep 5

    checkPidAlive
done

total_time=counter*5

if [[ (( counter -ge max_counter )) ]];
then
    printf "\n$(date) Server failed to start in $total_time seconds!\n"
    exit 1;
fi

printf "\n$(date) Server started in $total_time seconds!\n"

exit 0;
