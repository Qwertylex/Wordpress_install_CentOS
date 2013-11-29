#!/bin/bash
wget http://wordpress.org/latest.tar.gz ;
tar -zxf latest.tar.gz ;
yum install -y php php-mysql mysql-server httpd php-gd ;

service mysqld start ;
service httpd start ;
chkconfig httpd on ;
chkconfig mysqld on ;

echo -n -e "Enter the MySQL root password: \n"
read -s rootpw
echo -n -e "Enter database name: \n"
read dbname
echo -n -e "Enter database username: \n"
read dbuser
echo -n -e "Enter database user password: \n"
read -s dbpw
db="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"

echo "<?php phpinfo(); ?>" > /var/www/html/info.php ; 
sed -i 's/max_execution_time = 30/max_execution_time = 120/g' /etc/php.ini ;
sed -i 's/max_upload_size = 2M/max_upload_size = 50M/g' /etc/php.ini ;

chmod 0755 /var/www/html/info.php ;
touch /etc/httpd/conf.d/info.conf ;

echo -e "Alias /html /var/www/html\n<Directory /var/www/html/>\norder deny,allow\ndeny from all\nallow from 127.0.0.1\n</Directory>" > /etc/httpd/conf.d/info.conf ;

cp ~/wordpress/wp-config-sample.php ~/wordpress/wp-config.php ;
sed -i "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', '$dbname');/g" ~/wordpress/wp-config.php ;
sed -i "s/define('DB_USER', 'username_here');/define('DB_USER', '$dbuser');/g" ~/wordpress/wp-config.php ;
sed -i "s/define('DB_PASSWORD', 'password_here');/define('DB_PASSWORD', '$dbpw');/g" ~/wordpress/wp-config.php ;
cp -r ~/wordpress/* /var/www/html ;
service httpd restart ;
