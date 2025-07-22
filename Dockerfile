# # Use the latest version of the Amazon Linux base image
# FROM amazonlinux:2

# # Update all installed packages to thier latest versions
# RUN yum update -y 

# # Install the unzip package, which we will use it to extract the web files from the zip folder
# RUN yum install unzip -y

# # Install wget package, which we will use it to download files from the internet 
# RUN yum install -y wget

# # Install Apache
# RUN yum install -y httpd

# # Install PHP and various extensions
# RUN amazon-linux-extras enable php7.4 && \
#   yum clean metadata && \
#   yum install -y \
#     php \
#     php-common \
#     php-pear \
#     php-cgi \
#     php-curl \
#     php-mbstring \
#     php-gd \
#     php-mysqlnd \
#     php-gettext \
#     php-json \
#     php-xml \
#     php-fpm \
#     php-intl \
#     php-zip

# # Download the MySQL repository package
# RUN wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm

# # Import the GPG key for the MySQL repository
# RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# # Install the MySQL repository package
# RUN yum localinstall mysql80-community-release-el7-3.noarch.rpm -y

# # Install the MySQL community server package
# RUN yum install mysql-community-server -y

# # Change directory to the html directory
# WORKDIR /var/www/html

# # Install Git
# RUN yum install -y git

# # Set the build argument directive
# ARG PERSONAL_ACCESS_TOKEN
# ARG GITHUB_USERNAME
# ARG REPOSITORY_NAME
# ARG WEB_FILE_ZIP
# ARG WEB_FILE_UNZIP
# ARG DOMAIN_NAME
# ARG RDS_ENDPOINT
# ARG RDS_DB_NAME
# ARG RDS_DB_USERNAME
# ARG RDS_DB_PASSWORD

# # Use the build argument to set environment variables 
# ENV PERSONAL_ACCESS_TOKEN=$PERSONAL_ACCESS_TOKEN 
# ENV GITHUB_USERNAME=$GITHUB_USERNAME
# ENV REPOSITORY_NAME=$REPOSITORY_NAME
# ENV WEB_FILE_ZIP=$WEB_FILE_ZIP
# ENV WEB_FILE_UNZIP=$WEB_FILE_UNZIP
# ENV DOMAIN_NAME=$DOMAIN_NAME
# ENV RDS_ENDPOINT=$RDS_ENDPOINT
# ENV RDS_DB_NAME=$RDS_DB_NAME
# ENV RDS_DB_USERNAME=$RDS_DB_USERNAME
# ENV RDS_DB_PASSWORD=$RDS_DB_PASSWORD

# # Clone the GitHub repository
# RUN git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${REPOSITORY_NAME}.git

# # Unzip the zip folder containing the web files
# RUN unzip ${REPOSITORY_NAME}/${WEB_FILE_ZIP} -d ${REPOSITORY_NAME}/

# # Copy the web files into the HTML directory
# RUN cp -av ${REPOSITORY_NAME}/${WEB_FILE_UNZIP}/. /var/www/html

# # Remove the repository we cloned
# RUN rm -rf ${REPOSITORY_NAME}

# # Enable the mod_rewrite setting in the httpd.conf file
# RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# # Give full access to the /var/www/html directory
# RUN chmod -R 777 /var/www/html

# # Give full access to the storage directory
# RUN chmod -R 777 storage/

# # Use the sed command to search the .env file for a line that starts with APP_ENV= and replace everything after the = character
# RUN sed -i '/^APP_ENV=/ s/=.*$/=production/' .env

# # Use the sed command to search the .env file for a line that starts with APP_URL= and replace everything after the = character
# RUN sed -i "/^APP_URL=/ s/=.*$/=https:\/\/${DOMAIN_NAME}\//" .env

# # Use the sed command to search the .env file for a line that starts with DB_HOST= and replace everything after the = character
# RUN sed -i "/^DB_HOST=/ s/=.*$/=${RDS_ENDPOINT}/" .env

# # Use the sed command to search the .env file for a line that starts with DB_DATABASE= and replace everything after the = character
# RUN sed -i "/^DB_DATABASE=/ s/=.*$/=${RDS_DB_NAME}/" .env

# # Use the sed command to search the .env file for a line that starts with DB_USERNAME= and replace everything after the = character
# RUN  sed -i "/^DB_USERNAME=/ s/=.*$/=${RDS_DB_USERNAME}/" .env

# # Use the sed command to search the .env file for a line that starts with DB_PASSWORD= and replace everything after the = character
# RUN  sed -i "/^DB_PASSWORD=/ s/=.*$/=${RDS_DB_PASSWORD}/" .env

# # Print the .env file to review values
# RUN cat .env

# # Copy the file, AppServiceProvider.php from the host file system into the container at the path app/Providers/AppServiceProvider.php
# COPY AppServiceProvider.php app/Providers/AppServiceProvider.php

# # Expose the default Apache and MySQL ports
# EXPOSE 80 3306

# # Start Apache and MySQL
# ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# FROM amazonlinux:2

# RUN yum update -y && \
#     yum install -y unzip wget git httpd php php-mysqlnd php-xml php-mbstring php-json php-cli php-common && \
#     yum clean all

# # Enable Apache mod_rewrite
# RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# WORKDIR /var/www/html

# # Set build args and env
# ARG PERSONAL_ACCESS_TOKEN
# ARG GITHUB_USERNAME
# ARG REPOSITORY_NAME
# ARG WEB_FILE_ZIP
# ARG WEB_FILE_UNZIP
# ARG DOMAIN_NAME
# ARG RDS_ENDPOINT
# ARG RDS_DB_NAME
# ARG RDS_DB_USERNAME
# ARG RDS_DB_PASSWORD

# ENV DOMAIN_NAME=$DOMAIN_NAME
# ENV RDS_ENDPOINT=$RDS_ENDPOINT
# ENV RDS_DB_NAME=$RDS_DB_NAME
# ENV RDS_DB_USERNAME=$RDS_DB_USERNAME
# ENV RDS_DB_PASSWORD=$RDS_DB_PASSWORD

# # Clone and unzip Laravel app
# RUN git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${REPOSITORY_NAME}.git && \
#     unzip ${REPOSITORY_NAME}/${WEB_FILE_ZIP} -d ${REPOSITORY_NAME}/ && \
#     cp -av ${REPOSITORY_NAME}/${WEB_FILE_UNZIP}/. . && \
#     rm -rf ${REPOSITORY_NAME}

# # Update Laravel .env values
# RUN sed -i "/^APP_ENV=/ s/=.*$/=production/" .env && \
#     sed -i "/^APP_URL=/ s|=.*$|=https://${DOMAIN_NAME}/|" .env && \
#     sed -i "/^DB_HOST=/ s/=.*$/${RDS_ENDPOINT}/" .env && \
#     sed -i "/^DB_DATABASE=/ s/=.*$/${RDS_DB_NAME}/" .env && \
#     sed -i "/^DB_USERNAME=/ s/=.*$/${RDS_DB_USERNAME}/" .env && \
#     sed -i "/^DB_PASSWORD=/ s/=.*$/${RDS_DB_PASSWORD}/" .env

# # Laravel permissions
# RUN chmod -R 775 storage bootstrap/cache

# # Expose Apache
# EXPOSE 80

# # Start Apache in foreground
# CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# Use Amazon Linux 2023 base image
FROM amazonlinux:2023

# Update packages
RUN dnf update -y

# Install required packages (added essential Laravel PHP extensions)
RUN dnf install -y unzip wget git httpd php php-cli php-mysqlnd php-common \
    php-pdo php-mbstring php-json php-xml php-gd php-intl php-opcache php-fpm php-zip \
    php-curl php-dom php-session php-tokenizer php-fileinfo && \
    dnf clean all

# Change directory to Apache web root
WORKDIR /var/www/html

# Set build argument directive
ARG PERSONAL_ACCESS_TOKEN
ARG GITHUB_USERNAME
ARG REPOSITORY_NAME
ARG WEB_FILE_ZIP
ARG WEB_FILE_UNZIP
ARG DOMAIN_NAME
ARG RDS_ENDPOINT
ARG RDS_DB_NAME
ARG RDS_DB_USERNAME
ARG RDS_DB_PASSWORD

# Set environment variables
ENV PERSONAL_ACCESS_TOKEN=$PERSONAL_ACCESS_TOKEN 
ENV GITHUB_USERNAME=$GITHUB_USERNAME
ENV REPOSITORY_NAME=$REPOSITORY_NAME
ENV WEB_FILE_ZIP=$WEB_FILE_ZIP
ENV WEB_FILE_UNZIP=$WEB_FILE_UNZIP
ENV DOMAIN_NAME=$DOMAIN_NAME
ENV RDS_ENDPOINT=$RDS_ENDPOINT
ENV RDS_DB_NAME=$RDS_DB_NAME
ENV RDS_DB_USERNAME=$RDS_DB_USERNAME
ENV RDS_DB_PASSWORD=$RDS_DB_PASSWORD

# Clone the GitHub repository and prepare the application
RUN git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${REPOSITORY_NAME}.git && \
    unzip ${REPOSITORY_NAME}/${WEB_FILE_ZIP} -d ${REPOSITORY_NAME}/ && \
    cp -av ${REPOSITORY_NAME}/${WEB_FILE_UNZIP}/. /var/www/html && \
    rm -rf ${REPOSITORY_NAME}

# Enable Apache mod_rewrite
RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Set proper file permissions for Apache (improved from 777)
RUN chown -R apache:apache /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 storage/ bootstrap/cache/ 2>/dev/null || true

# Update .env values (added error handling)
RUN if [ -f .env ]; then \
        sed -i '/^APP_ENV=/ s/=.*$/=production/' .env && \
        sed -i "/^APP_URL=/ s|=.*$|=https://${DOMAIN_NAME}/|" .env && \
        sed -i "/^DB_HOST=/ s/=.*$/=${RDS_ENDPOINT}/" .env && \
        sed -i "/^DB_DATABASE=/ s/=.*$/=${RDS_DB_NAME}/" .env && \
        sed -i "/^DB_USERNAME=/ s/=.*$/=${RDS_DB_USERNAME}/" .env && \
        sed -i "/^DB_PASSWORD=/ s/=.*$/=${RDS_DB_PASSWORD}/" .env; \
    else \
        echo "No .env file found, creating basic one..."; \
        echo "APP_NAME=Laravel" > .env && \
        echo "APP_ENV=production" >> .env && \
        echo "APP_DEBUG=false" >> .env && \
        echo "APP_URL=https://${DOMAIN_NAME}" >> .env && \
        echo "DB_CONNECTION=mysql" >> .env && \
        echo "DB_HOST=${RDS_ENDPOINT}" >> .env && \
        echo "DB_PORT=3306" >> .env && \
        echo "DB_DATABASE=${RDS_DB_NAME}" >> .env && \
        echo "DB_USERNAME=${RDS_DB_USERNAME}" >> .env && \
        echo "DB_PASSWORD=${RDS_DB_PASSWORD}" >> .env; \
    fi

# Print .env for verification
RUN cat .env

# Copy Laravel provider override file (with error handling)
COPY AppServiceProvider.php app/Providers/AppServiceProvider.php

# Create health check endpoint for ALB
RUN echo '<?php' > /var/www/html/health.php && \
    echo 'http_response_code(200);' >> /var/www/html/health.php && \
    echo 'echo "OK";' >> /var/www/html/health.php && \
    echo '?>' >> /var/www/html/health.php

# Configure Apache properly for container environment
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf && \
    sed -i 's/^#ServerName www.example.com:80/ServerName localhost:80/' /etc/httpd/conf/httpd.conf && \
    echo "PidFile /var/run/httpd/httpd.pid" >> /etc/httpd/conf/httpd.conf

# Create httpd PID directory
RUN mkdir -p /var/run/httpd && \
    chown apache:apache /var/run/httpd

# Create startup script for graceful shutdown handling
RUN echo '#!/bin/bash' > /usr/local/bin/start-server.sh && \
    echo 'set -e' >> /usr/local/bin/start-server.sh && \
    echo '' >> /usr/local/bin/start-server.sh && \
    echo '# Create PID directory' >> /usr/local/bin/start-server.sh && \
    echo 'mkdir -p /var/run/httpd' >> /usr/local/bin/start-server.sh && \
    echo 'chown apache:apache /var/run/httpd' >> /usr/local/bin/start-server.sh && \
    echo '' >> /usr/local/bin/start-server.sh && \
    echo '# Function to handle shutdown gracefully' >> /usr/local/bin/start-server.sh && \
    echo 'shutdown_handler() {' >> /usr/local/bin/start-server.sh && \
    echo '    echo "Received shutdown signal, stopping Apache gracefully..."' >> /usr/local/bin/start-server.sh && \
    echo '    /usr/sbin/httpd -k graceful-stop' >> /usr/local/bin/start-server.sh && \
    echo '    exit 0' >> /usr/local/bin/start-server.sh && \
    echo '}' >> /usr/local/bin/start-server.sh && \
    echo '' >> /usr/local/bin/start-server.sh && \
    echo '# Trap shutdown signals' >> /usr/local/bin/start-server.sh && \
    echo 'trap shutdown_handler SIGTERM SIGINT SIGQUIT' >> /usr/local/bin/start-server.sh && \
    echo '' >> /usr/local/bin/start-server.sh && \
    echo '# Test Apache configuration' >> /usr/local/bin/start-server.sh && \
    echo 'echo "Testing Apache configuration..."' >> /usr/local/bin/start-server.sh && \
    echo '/usr/sbin/httpd -t' >> /usr/local/bin/start-server.sh && \
    echo '' >> /usr/local/bin/start-server.sh && \
    echo '# Start Apache' >> /usr/local/bin/start-server.sh && \
    echo 'echo "Starting Apache web server..."' >> /usr/local/bin/start-server.sh && \
    echo 'exec /usr/sbin/httpd -D FOREGROUND' >> /usr/local/bin/start-server.sh && \
    chmod +x /usr/local/bin/start-server.sh

# Expose only HTTP port (removed MySQL port since using RDS)
EXPOSE 80

# Use the startup script for better signal handling
ENTRYPOINT ["/usr/local/bin/start-server.sh"]