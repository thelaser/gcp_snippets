#!/bin/sh

sudo apt install php less nginx mariadb-server -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
mysql -uroot -p -e "CREATE USER 'wpuser' IDENTIFIED BY 'mypersonalpassword'; GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'; FLUSH PRIVILEGES;"
