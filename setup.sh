# !/bin/bash

# Run this script using the following:
#   curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/cyberbootcamp/vagrant-lab01/master/setup.sh | bash

# This script created from tinyurl.com/vzbyfzw

sudo apt install -y curl ansible

exit
# Create demo directory for instructor
mkdir -p /home/instructor/Documents/demo
cd /home/instructor/Documents/demo

# Upgrade and download docker file instructor
# (two files exist in the script that create the same docker-compose.yml file)
# cat <<EOF > /home/instructor/Documents/demo/docker-compose.yml
# version: "3.7"

# services:
#   ui:
#     image: httpd:2.4
#     ports:
#       - 10000-10003:8080
#     volumes:
#       - ./volume:/home
#     networks:
#       demo-net:
#   db:
#     image: mariadb:10.5.1
#     restart: always
#     environment:
#       MYSQL_DATABASE: demodb
#       MYSQL_USER: demouser
#       MYSQL_PASSWORD: demopass
#       MYSQL_RANDOM_ROOT_PASSWORD: "1"
#     volumes:
#       - db:/var/lib/mysql
#     networks:
#       demo-net:
#         ipv4_address: 192.168.1.3
# networks:
#   demo-net:
#     ipam:
#       driver: default
#       config:
#         - subnet: "192.168.1.0/24"
# volumes:
#   ui:
#   db:
# EOF

# Download class demo
cat <<EOF > /home/instructor/Documents/demo/docker-compose.yml
version: "3.7"

services:
  wordpress:
    image: wordpress:4.6.1-php5.6-apache
    restart: always
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - wordpress:/var/www/html
      - ./volume:/var/www/html/volume
    container_name: wp
    networks:
      app-net:

  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: "1"
    volumes:
      - db:/var/lib/mysql
    container_name: db
    networks:
      app-net:

  ui:
    image: httpd:2.4
    ports:
      - 10000-10003:80
    volumes:
      - ./volume:/home
    networks:
      app-net:

networks:
  app-net:
    ipam:
      driver: default
      config:
        - subnet: "10.0.2.0/24"

volumes:
  wordpress:
  db:
  ui:
EOF

# Install trivy script
cat <<EOF > /home/instructor/Documents/demo/trivy.sh
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
# Clean up trivy.list file
sudo awk '!x[$0]++' /etc/apt/sources.list.d/trivy.list > /tmp/trivy.list_bak
sudo cp /tmp/trivy.list_bak /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y 
sudo apt-get install -y trivy
EOF

# Download and make falco.sh executable 
cat <<EOF > /home/instructor/Documents/demo/falco.sh
sudo falco service stop #if installed locally on Linux as a non-container
docker container rm falco
# docker pull falcosecurity/falco
# docker run -i -t \
#     --name falco \
#     --privileged \
#     -v /var/run/docker.sock:/host/var/run/docker.sock \
#     -v /dev:/host/dev \
#     -v /proc:/host/proc:ro \
#     -v /boot:/host/boot:ro \
#     -v /lib/modules:/host/lib/modules:ro \
#     -v /usr:/host/usr:ro \
#     falcosecurity/falco

docker run \
  --interactive \
  --privileged \
  --tty \
  --name falco \
  --volume /var/run/docker.sock:/host/var/run/docker.sock \
  --volume /dev:/host/dev \
  --volume /proc:/host/proc:ro \
  --volume /boot:/host/boot:ro \
  --volume /lib/modules:/host/lib/modules:ro \
  --volume /usr:/host/usr:ro \
  falcosecurity/falco:0.19.0
EOF

# Recursively give all /home/instructor/Documents/demo files to instructor user and group
sudo chown -R instructor: /home/instructor/Documents/demo

# Add execute permissions for trivy.sh and falco.sh
chmod +x /home/instructor/Documents/demo/trivy.sh
chmod +x /home/instructor/Documents/demo/falco.sh

# Run the trivy.sh script
/home/instructor/Documents/demo/trivy.sh
# /home/instructor/Documents/demo/falco.sh