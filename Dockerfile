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

# Overwrite the default server.xml using cat
RUN cat <<EOL > /opt/tomcat/conf/server.xml
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <!-- Remove the HTTP Connector -->
    <!-- Configure HTTPS Connector on port 4041 -->
    <Connector port="4041" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true" >
      <SSLHostConfig>
        <Certificate certificateKeyFile="conf/ca-key.pem"
                     certificateFile="conf/ca-cert.pem"
                     type="RSA" />
      </SSLHostConfig>
    </Connector>
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
      </Realm>
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
EOL

# Copy the CA PEM files
COPY ca-cert.pem /opt/tomcat/conf/ca-cert.pem
COPY ca-key.pem /opt/tomcat/conf/ca-key.pem

# Start Tomcat with SSL/TLS
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
