# Use CentOS 7 as the base image
FROM centos:7

# Expose port 4041 for Tomcat
EXPOSE 4041

# Install necessary software
RUN yum -y install java-1.8.0-openjdk openssl && \
    yum -y clean all

# Download and install Tomcat 8.5
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.77/bin/apache-tomcat-8.5.77.tar.gz && \
    tar xzf apache-tomcat-8.5.77.tar.gz && \
    mv apache-tomcat-8.5.77 /opt/tomcat && \
    rm -f apache-tomcat-8.5.77.tar.gz

# Copy your sample web app to the Tomcat webapps directory
COPY sample.war /opt/tomcat/webapps/sample.war

# Overwrite the default server.xml by using echo
RUN echo '<?xml version="1.0" encoding="UTF-8"?>' > /opt/tomcat/conf//server.xml \
    && echo '<Server port="8005" shutdown="SHUTDOWN">' >> /opt/tomcat/conf//server.xml \
    && echo '  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />' >> /opt/tomcat/conf//server.xml \
    && echo '  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />' >> /opt/tomcat/conf//server.xml \
    && echo '  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />' >> /opt/tomcat/conf//server.xml \
    && echo '  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />' >> /opt/tomcat/conf//server.xml \
    && echo '  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />' >> /opt/tomcat/conf//server.xml \
    && echo '  <GlobalNamingResources>' >> /opt/tomcat/conf//server.xml \
    && echo '    <Resource name="UserDatabase" auth="Container"' >> /opt/tomcat/conf//server.xml \
    && echo '              type="org.apache.catalina.UserDatabase"' >> /opt/tomcat/conf//server.xml \
    && echo '              description="User database that can be updated and saved"' >> /opt/tomcat/conf//server.xml \
    && echo '              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"' >> /opt/tomcat/conf//server.xml \
    && echo '              pathname="conf/tomcat-users.xml" />' >> /opt/tomcat/conf//server.xml \
    && echo '  </GlobalNamingResources>' >> /opt/tomcat/conf//server.xml \
    && echo '  <Service name="Catalina">' >> /opt/tomcat/conf//server.xml \
    && echo '    <!-- Remove the HTTP Connector -->' >> /opt/tomcat/conf//server.xml \
    && echo '    <!-- Configure HTTPS Connector on port 4041 -->' >> /opt/tomcat/conf//server.xml \
    && echo '    <Connector port="4041" protocol="org.apache.coyote.http11.Http11NioProtocol"' >> /opt/tomcat/conf//server.xml \
    && echo '               maxThreads="150" SSLEnabled="true" >' >> /opt/tomcat/conf//server.xml \
    && echo '        <SSLHostConfig>' >> /opt/tomcat/conf//server.xml \
    && echo '            <Certificate certificateKeyFile="conf/ca-key.pem"' >> /opt/tomcat/conf//server.xml \
    && echo '                         certificateFile="conf/ca-cert.pem"' >> /opt/tomcat/conf//server.xml \
    && echo '                         type="RSA" />' >> /opt/tomcat/conf//server.xml \
    && echo '        </SSLHostConfig>' >> /opt/tomcat/conf//server.xml \
    && echo '    </Connector>' >> /opt/tomcat/conf//server.xml \
    && echo '    <Engine name="Catalina" defaultHost="localhost">' >> /opt/tomcat/conf//server.xml \
    && echo '      <Realm className="org.apache.catalina.realm.LockOutRealm">' >> /opt/tomcat/conf//server.xml \
    && echo '        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>' >> /opt/tomcat/conf//server.xml \
    && echo '      </Realm>' >> /opt/tomcat/conf//server.xml \
    && echo '      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">' >> /opt/tomcat/conf//server.xml \
    && echo '        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"' >> /opt/tomcat/conf//server.xml \
    && echo '               prefix="localhost_access_log" suffix=".txt"' >> /opt/tomcat/conf//server.xml \
    && echo '               pattern="%h %l %u %t &quot;%r&quot; %s %b" />' >> /opt/tomcat/conf//server.xml \
    && echo '      </Host>' >> /opt/tomcat/conf//server.xml \
    && echo '    </Engine>' >> /opt/tomcat/conf//server.xml \
    && echo '  </Service>' >> /opt/tomcat/conf//server.xml \
    && echo '</Server>' >> /opt/tomcat/conf//server.xml

# Copy the CA PEM files
COPY ca-cert.pem /opt/tomcat/conf/ca-cert.pem
COPY ca-key.pem /opt/tomcat/conf/ca-key.pem

# Start Tomcat with SSL/TLS
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
