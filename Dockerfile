#Web with php version 7.4
FROM php:7.4-apache
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo pdo_mysql
RUN apt-get update && apt-get -y install libpng-dev
RUN docker-php-ext-install gd
RUN apt install git -y
COPY ./DVWA/ /var/www/html/DVWA/
COPY ./DVWA/php.ini /usr/local/etc/php/
RUN chmod 777 /var/www/html/DVWA/hackable/uploads/
RUN chmod 777 /var/www/html/DVWA/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
RUN chmod 777 /var/www/html/DVWA/config
RUN cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
#Installing ModSecurity
RUN apt install libapache2-mod-security2 -y
RUN a2enmod headers
#Configuring ModSecurity
COPY ./modsecurity.conf /etc/modsecurity/
#Setting Up the OWASP ModSecurity Core Rule Set
RUN rm -rf /usr/share/modsecurity-crs
RUN git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
RUN mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
RUN mv /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
#Enabling ModSecurity in Apache 2
COPY ./security2.conf /etc/apache2/mods-available/
COPY ./000-default.conf /etc/apache2/sites-enabled/
#Cambia de archivo
mv /usr/share/modsecurity-crs/rules/REQUEST-922-MULTIPART-ATTACK.conf /usr/share/modsecurity-crs/rules/REQUEST-922-MULTIPART-ATTACK.conf.example

EXPOSE 80


