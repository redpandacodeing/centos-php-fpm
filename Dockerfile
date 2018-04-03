FROM centos:7
MAINTAINER 'Jordan Wamser <jwamser@redpandacoding.com>'
ARG DEV='dev'
ARG FPM_PORT=9000
ENV APP_ENV=${DEV}

# build centos commands
RUN yum update -y && \
    yum install -y epel-release

# add remi repo bundles
RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php72 && \
    yum -y update

### START INSTALL MSSQL ###
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

RUN ACCEPT_EULA=Y yum install -y msodbcsql unixODBC-devel
### FINISHED MSSQL INSTALL

### DEV > START INSTALL XDEBUG ###
RUN if [ "${APP_ENV}" != "prod" ]; then \
          yum install -y php-xdebug; \
       fi
### DEV > FINISH INSTALL XDEBUG ###

# install php and needed php modules && sqlsrv
RUN yum install -y php-fpm \
 php-zip \
 php-xml \
 php-cli \
 php-bcmath \
 php-dba \
 php-gd \
 php-intl \
 php-mbstring \
 php-mysql \
 php-pdo \
 php-soap \
 php-pecl-apcu \
 php-pecl-imagick \
 php-opcache \
 php-process \
 php-sqlsrv

RUN useradd -M -d /opt/app -s /bin/false nginx \
    && mkdir /opt/app

COPY ./php-fpm.conf /etc/php-fpm.conf
COPY ./www.conf /etc/php-fpm.d/www.conf
COPY ./ini/. /etc/.
COPY ./start_php.sh /

EXPOSE ${FPM_PORT}

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

RUN chown -R -v root:nginx /var/lib/php \
    && chown -R -v root:nginx /opt/app

RUN yum clean all

CMD sh /start_php.sh