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

# Configuring SSL

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


# Configuring NGINX
sudo apt-get install nginx -y
sudo systemctl restart nginx.service

if $varnaked;
  then sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhynet/wordpress-install/main/php74/config.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var01/g" /etc/nginx/sites-enabled/"$var01";
elif $varwww;
  then sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhynet/wordpress-install/main/php74/config-www.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var011/g" /etc/nginx/sites-enabled/"$var01";
else 
  sudo wget --no-check-certificate 'https://raw.githubusercontent.com/yudhynet/wordpress-install/main/php74/config-non-www.txt' -O /etc/nginx/sites-enabled/"$var01" && sudo sed -i "s/domain/$var01/g" /etc/nginx/sites-enabled/"$var01";
fi

# installing the app 
cd /tmp
sudo wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress "$var01"
cd
sudo mv /tmp/"$var01" /var/www/"$var01"
sudo chown -R www-data:www-data /var/www/"$var01"
sudo chmod -R 0755 /var/www/"$var01"

# Removing obsolete files
sudo rm /tmp/latest.tar.gz


# Restrating services
sudo systemctl restart nginx.service
sudo systemctl restart mysql.service
sudo systemctl restart php7.4-fpm

echo "========== Info =========="
echo "Domain Terinstall: $var01"
echo "========================= Selesai ! ============================"
echo "=========== CMS Wordpress berhasil Di Upload=========="
echo "=================== =================== ====================="
