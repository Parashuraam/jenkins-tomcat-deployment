FROM centos:latest

MAINTAINER parshuram.kurma@gmail.com

RUN mkdir -p /opt/app/tomcat/

WORKDIR /opt/app/tomcat

RUN curl -O https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz

RUN tar xvfz apache-tomcat-8.5.61.tar.gz

RUN yum -y install java

RUN java -version

WORKDIR /opt/app/tomcat/apache-tomcat-8.5.61/webapp

add target/HelloWorld*.war /opt/app/tomcat/apache-tomcat-8.5.61/webapp/HelloWorld.war

RUN touch HelloWorld.war

EXPOSE 8080

CMD ["/opt/app/tomcat/apache-tomcat-8.5.61/bin/catalina.sh", "run"]
