FROM centos:7
MAINTAINER Rodrigo Zechin rosauro <rodrigo.zr@gmail.com>

# Enable the EPEL repo. The repo package is part of centos base so no need fetch it.
RUN yum -y install epel-release

# Fetch and enable the RPMFusion repo
RUN yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm

# Install the latest *release* of zoneminder
RUN yum -y install zoneminder mariadb-server zip

# Initialize the database server
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql/

# Set our volumes before we attempt to configure apache
VOLUME /var/lib/zoneminder/images /var/lib/zoneminder/events /var/lib/mysql /var/log/zoneminder

# Configure Apache
RUN echo "ServerName localhost" > /etc/httpd/conf.d/servername.conf
RUN echo -e "# Redirect the webroot to /zm\nRedirectMatch permanent ^/$ /zm" > /etc/httpd/conf.d/redirect.conf
ADD zoneminder.conf /etc/httpd/conf.d/zoneminder.conf

# Expose http port
EXPOSE 80

# Get the entrypoint script and make sure it is executable
ADD https://raw.githubusercontent.com/ZoneMinder/zmdockerfiles/master/utils/entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh

# This is run each time the container is started
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

ENV TZ=America/Sao_Paulo

################
# RUN EXAMPLES #
################

# ZoneMinder uses /dev/shm for shared memory and many users will need to increase 
# the size significantly at runtime like so:
#
# docker run -d -t -p 1080:80 \
#    --shm-size="512m" \
#    --name zoneminder \
#    rodrigozr/zoneminder

# ZoneMinder checks the TZ environment variable at runtime to determine the timezone.
# If this variable is not set, then ZoneMinder will default to UTC.
# Alternaitvely, the timezone can be set manually like so:
#
# docker run -d -t -p 1080:80 \
#    -e TZ='America/Sao_Paulo' \
#    --name zoneminder \
#    rodrigozr/zoneminder

# ZoneMinder can write its data to folders outside the container using volumes.
#
# docker run -d -t -p 1080:80 \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/mysql:/var/lib/mysql \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --name zoneminder \
#    rodrigozr/zoneminder

# ZoneMinder can use an external database by setting the appropriate environment variables.
#
# docker run -d -t -p 1080:80 \
#    -e ZM_DB_USER='zmuser' \
#    -e ZM_DB_PASS='zmpassword' \
#    -e ZM_DB_NAME='zoneminder_database' \
#    -e ZM_DB_HOST='my_central_db_server' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --name zoneminder \
#    rodrigozr/zoneminder

# Here is an example using the options described above with the internal database:
#
# docker run -d -t -p 1080:80 \
#    -e TZ='America/Sao_Paulo' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/mysql:/var/lib/mysql \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --shm-size="512m" \
#    --name zoneminder \
#    rodrigozr/zoneminder

# Here is an example using the options described above with an external database:
#
# docker run -d -t -p 1080:80 \
#    -e TZ='America/Sao_Paulo' \
#    -e ZM_DB_USER='zmuser' \
#    -e ZM_DB_PASS='zmpassword' \
#    -e ZM_DB_NAME='zoneminder_database' \
#    -e ZM_DB_HOST='my_central_db_server' \
#    -v /disk/zoneminder/events:/var/lib/zoneminder/events \
#    -v /disk/zoneminder/images:/var/lib/zoneminder/images \
#    -v /disk/zoneminder/logs:/var/log/zm \
#    --shm-size="512m" \
#    --name zoneminder \
#    rodrigozr/zoneminder

