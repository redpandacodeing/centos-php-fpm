FROM centos:7
MAINTAINER 'Jordan Wamser <jwamser@redpandacoding.com>'
ARG DEV=1
ENV DEV_SERVER=${DEV}

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
RUN if [ -n "${DEV_SERVER}" ]; then \
          yum install -y php-xdebug; \
       fi
### DEV > FINISH INSTALL XDEBUG ###

# install php and needed php modules && sqlsrv
RUN yum install -y php-fpm \
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

RUN useradd -M -d /opt/app -s /bin/false nginx

COPY ./php-fpm.conf /etc/php-fpm.conf
COPY ./www.conf /etc/php-fpm.d/www.conf
COPY ./ini/. /etc/.

RUN yum clean all

CMD php-fpm