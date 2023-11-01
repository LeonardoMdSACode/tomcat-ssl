# Tomcat Docker Deployment with SSL/TLS

This is a Dockerized deployment of a sample Tomcat web application with SSL/TLS enabled on port 4041.

## How to Build and Run

1. Make sure you have Docker installed on your system.

2. Clone this repository:

   ```bash
   git clone https://github.com/your-username/tomcat-docker-ssl.git
   cd tomcat-docker-ssl
   ```

3. Build docker image

   ```bash
    docker build -t tomcat-ssl .
    ```

4. Run docker

   ```bash
    docker run -p 4041:4041 tomcat-ssl
   ```

5. Test the app

   You can access the app using the following url: https://localhost:4041/sample

Note: openssl was used to generate the private key and a self-signed certificate with the following commands:

Generate CA private key (ca.key.pem)
   ```bash
   openssl genpkey -algorithm RSA -out ca-key.pem
   ```
Generate CA public certificate (ca.crt.pem)
   ```bash
   openssl req -new -x509 -key ca-key.pem -out ca-cert.pem -subj "/CN=Leo"
   ```
