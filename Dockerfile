FROM centos:latest

MAINTAINER parshuram.kurma@gmail.com

RUN mkdir /opt/tomcat/

WORKDIR /opt/tomcat
RUN curl -O https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-8.5.61/* /opt/tomcat/.
RUN yum -y install java
RUN java -version

WORKDIR /opt/tomcat/webapps
COPY target/HelloWorld*.war HelloWorld.war

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
