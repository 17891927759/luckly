# Dockerfile for luck-application
# 1. Copy luck-application-${VERSION}.zip to current directory
# 2. Build with: docker build -t luck-application .
# 3. Run with: docker run -p 8090:8090 -d -v /tmp/logs:/opt/logs --name luck-application luck-application

FROM openjdk:8-jre-alpine
#FROM base/java
MAINTAINER roc.wong <roc.fly@qq.com>


ENV VERSION 1.0-SNAPSHOT

# 安装tzdata后，会在/usr/share/zoneinfo目录下生成各时区配置信息，Alpine目录并无timezone及locatime配置

RUN echo "https://mirrors.aliyun.com/alpine/v3.9/main" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v3.9/community" >> /etc/apk/repositories \
    && apk update upgrade \
    && apk add --no-cache procps unzip curl bash tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

ADD ./luck-application-${VERSION}.zip /luck-application/luck-application-${VERSION}.zip

RUN unzip /luck-application/luck-application-${VERSION}.zip -d /luck-application \
    && rm -rf /luck-application/luck-application-${VERSION}.zip \
    && sed -i '$d' /luck-application/scripts/startup.sh \
    && echo "tail -f /dev/null" >> /luck-application/scripts/startup.sh

EXPOSE 8080

CMD ["/luck-application/scripts/startup.sh"]
