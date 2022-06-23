#! /bin/bash

echo "================================================================"
echo "============= Selamat datang di penginstal CMS Wordpress ==========="
echo "================================================================"
echo -n "Masukkan nama domain Anda > "
read var01
echo -n "Masukkan alamat email Anda > "
read var02

var011=`echo "$var01" | sudo sed "s/www.//g"`
varnaked=`echo "$var01" | grep -q -E '(.+\.)+.+\..+$' || echo "true" && echo "false"`
varwww=`echo "$var01" | grep -q "www." && echo "true" || echo "false"`


echo ""

if $varnaked;
  then echo "Pastikan '$var01' & 'www.$var01' keduanya mengarah ke alamat IP server Anda, jika tidak, instalasi akan gagal";
elif $varwww;
  then echo "Pastikan '$var011' & '$var01' keduanya mengarah ke alamat IP server Anda, jika tidak, instalasi akan gagal";
else 
  echo "Pastikan '$var01' arahkan ke alamat IP server Anda, jika tidak, instalasi akan gagal";
fi

echo ""


echo -n "Tekan 'y' Untuk Melanjutkan > "
read varinput
echo "Yy" | grep -q "$varinput" && echo "melanjutkan..." || echo "keluar..."
echo "Yy" | grep -q "$varinput" || exit 1


echo "================================================================"
echo "======== Robot sekarang Untuk menginstal CMS Wordpress  ======="
echo "========================== install berjalan kurang lebih 120detik =========================="
echo "================================================================"

# initial setup
sudo apt-get update
sudo apt-get install pwgen -y
sudo apt-get install gpw -y
sudo apt-get install nano -y
sudo apt-get install software-properties-common -y
sudo apt-get install mariadb-server mariadb-client -y
sudo apt-get install certbot -y
sudo apt-get install cron -y

sudo apt disable ufw -y
sudo apt remove iptables -y
sudo apt purge iptables -y


# random string generation
var03=$(gpw 1 8)
var04=$(gpw 1 8)
var05=$(pwgen -s 16 1)
var06=$(pwgen -s 16 1)


# STEP1 configuring PHP
echo | sudo add-apt-repository ppa:ondrej/php
echo | sudo add-apt-repository ppa:ondrej/nginx-mainline
sudo apt-get update
#sudo apt-get install php7.4-fpm php7.4-common php7.4-mysql php7.4-gmp php7.4-curl php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-gd php7.4-xml php7.4-cli php7.4-zip php7.4-soap php7.4-imagick -y
sudo apt install php7.4-fpm php7.4-imagick php7.4-common php7.4-mysql php7.4-gmp php7.4-imap php7.4-json php7.4-pgsql php7.4-ssh2 php7.4-sqlite3 php7.4-ldap php7.4-curl php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-gd php7.4-xml php7.4-cli php7.4-zip php7.4-soap -y

sudo bash -c 'echo short_open_tag = On >> /etc/php/7.4/fpm/php.ini'
sudo bash -c 'echo cgi.fix_pathinfo = 0 >> /etc/php/7.4/fpm/php.ini'
sudo bash -c 'echo date.timezone = Asia/Jakarta >> /etc/php/7.4/fpm/php.ini'
sudo sed -i "s/max_execution_time = 30/max_execution_time = 600/g" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 64M/g" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 64M/g" /etc/php/7.4/fpm/php.ini


# STEP2 configuring DATABASE
sudo mysql -u root -e "CREATE DATABASE $var03;"
sudo mysql -u root -e "CREATE USER '$var04'@'localhost' IDENTIFIED BY '$var05';"
sudo mysql -u root -e "GRANT ALL ON $var03.* TO '$var04'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
sudo mysqladmin password "$var06"
sudo mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -e "DROP DATABASE IF EXISTS test;"
sudo mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"


# STEP3 configuring SSL

sudo systemctl stop nginx.service
sudo systemctl stop apache.service
sudo systemctl stop apache2.service

if $varnaked;
  then yes | sudo certbot certonly --non-interactive --standalone --preferred-challenges http --email "$var02" --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d "$var01" -d www."$var01";
elif $varwww;
  then yes | sudo certbot certonly --non-interactive --standalone --preferred-challenges http --email "$var02" --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d "$var01" -d "$var011";
else 
  yes | sudo certbot certonly --non-interactive --standalone --preferred-challenges http --email "$var02" --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d "$var01";
fi


# STEP4 configuring NGINX
sudo apt-get install nginx -y
sudo systemctl restart nginx.service

if $varnaked;
  then sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhymobi/wordpress-install/main/php74/config.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var01/g" /etc/nginx/sites-enabled/"$var01";
elif $varwww;
  then sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhymobi/wordpress-install/main/php74/config-www.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var011/g" /etc/nginx/sites-enabled/"$var01";
else 
  sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhymobi/wordpress-install/main/php74/config-non-www.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var01/g" /etc/nginx/sites-enabled/"$var01";
fi

# optional packages update
# sudo apt-get update
#sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
#sudo apt-get clean -y
#sudo apt-get autoclean -y
#sudo apt autoremove -y

# installing the app 
cd /tmp
sudo wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress "$var01"
cd
sudo mv /tmp/"$var01" /var/www/"$var01"
sudo chown -R www-data:www-data /var/www/"$var01"
sudo chmod -R 0755 /var/www/"$var01"

sudo mv /var/www/"$var01"/wp-config-sample.php /var/www/"$var01"/wp-config.php
sudo sed -i "s/database_name_here/$var03/g" /var/www/"$var01"/wp-config.php
sudo sed -i "s/username_here/$var04/g" /var/www/"$var01"/wp-config.php
sudo sed -i "s/password_here/$var05/g" /var/www/"$var01"/wp-config.php
sudo perl -i -pe'
   BEGIN {
     @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
     push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
     sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
   }
   s/put your unique phrase here/salt()/ge
 ' /var/www/"$var01"/wp-config.php 


# Removing obsolete files
sudo rm /tmp/latest.tar.gz


# Restrating services
sudo systemctl restart nginx.service
sudo systemctl restart mysql.service
sudo systemctl restart php7.4-fpm

echo "========== Info Login Database dan mysql =========="
echo "mysql username: root"
echo "mysql password: $var06"
echo "database name: $var03"
echo "database username: $var04"
echo "database password: $var05"
echo "========================= Selesai ! ============================"
echo "=========== CMS Wordpress berhasil diinstal =========="
echo "=================== =================== ====================="
