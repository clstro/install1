#!/bin/bash
echo Enter user/db name?
read username
pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

echo Updating packages...
apt update > /dev/null
atp -y upgrade > /dev/null

echo Installing basic packages...
apt install -y wget curl zip unzip p7zip > /dev/null

echo Installing PHP and extensions...
apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 > /dev/null
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
wget -qO - https://packages.sury.org/php/apt.gpg | sudo tee /usr/share/keyrings/apt.gpg > /dev/null
apt update > /dev/null
apt install -y php php-bcmath php-json php-mbstring php-mysql php-tokenizer php-xml php-zip > /dev/null

echo Installing database...
apt install -y mariadb-server mariadb-client > /dev/null
/etc/init.d/mariadb start

echo Creating database...
mysql -u root -e "CREATE DATABASE $username;"
mysql -u root -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$pass';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

echo Installing Composer...
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/bin/composer

echo Installing Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
apt install -y nodejs npm > /dev/null

echo Ready!
echo Username and database is $username
echo Password is $pass
