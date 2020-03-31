<!-- TOC -->autoauto- [1. PUB](#1-pub)auto    - [1.1. SOFT](#11-soft)auto        - [1.1.1. WINDOWS](#111-windows)auto        - [1.1.2. DUPLICATI](#112-duplicati)auto        - [1.1.3. APACHE](#113-apache)auto            - [1.1.3.1. Различные способы переадрессации](#1131-различные-способы-переадрессации)auto                - [1.1.3.1.1. htaccess](#11311-htaccess)auto        - [1.1.4. ZABBIX](#114-zabbix)auto            - [1.1.4.1. Установка клиента](#1141-установка-клиента)auto                - [1.1.4.1.1. Подготовка](#11411-подготовка)auto                - [1.1.4.1.2. Устанавливаем сам агент](#11412-устанавливаем-сам-агент)auto                - [1.1.4.1.3. Правим конфиг агента](#11413-правим-конфиг-агента)auto- [2. nano /etc/zabbix/zabbix_agent.conf](#2-nano-etczabbixzabbix_agentconf)auto                - [2.0.4.1.4. Добавим zabbix в sudoers](#20414-добавим-zabbix-в-sudoers)auto                - [2.0.4.1.5. Установим zabbix как службу systemd](#20415-установим-zabbix-как-службу-systemd)auto            - [2.0.4.2. Установка сервера](#2042-установка-сервера)auto            - [2.0.4.3. Установка сервера для docker-compose](#2043-установка-сервера-для-docker-compose)auto        - [2.0.5. KODI](#205-kodi)auto        - [2.0.6. ssh](#206-ssh)auto        - [2.0.7. PROXMOX](#207-proxmox)auto        - [2.0.8. WINE](#208-wine)auto            - [2.0.8.1. Install on Linux Mint 19.3](#2081-install-on-linux-mint-193)auto    - [2.1. OS](#21-os)auto    - [2.2. HW](#22-hw)auto    - [2.3. DevOps](#23-devops)auto        - [2.3.1. Docker](#231-docker)auto            - [2.3.1.1. Установка Docker + Docker-Compose](#2311-установка-docker--docker-compose)auto            - [2.3.1.2. Docker-Compose как systemd сервис](#2312-docker-compose-как-systemd-сервис)auto        - [2.3.2. Ротация логов](#232-ротация-логов)auto        - [2.3.3. Права на файлы](#233-права-на-файлы)auto    - [2.4. DEVELOP](#24-develop)auto        - [2.4.1. PHP](#241-php)auto            - [2.4.1.1. Проверка отправки почты через sendmail](#2411-проверка-отправки-почты-через-sendmail)auto        - [2.4.2. PYTHON](#242-python)auto            - [2.4.2.1. Ссылки](#2421-ссылки)auto        - [2.4.3. BITRIX](#243-bitrix)auto            - [2.4.3.1. Ссылки](#2431-ссылки)autoauto<!-- /TOC -->

# 1. PUB
Public Repo For Sysadmins and other people

Сначала вел документацию на WIKI (dockuwiki) сейчас же перешел на GitHUB.

[TOC]



## 1.1. SOFT

### 1.1.1. WINDOWS

- [Узнать размер папок (Scanner)](http://www.steffengerlach.de/freeware/scn2.zip)
- 

### 1.1.2. DUPLICATI

[Статья по установке](https://www.techgrube.de/tutorials/homeserver-nas-mit-ubuntu-18-04-teil-7-backups-mit-duplicati-und-rsnapshot)

### 1.1.3. APACHE

#### 1.1.3.1. Различные способы переадрессации

[Источник](https://afirewall.ru/redirekt-s-http-na-https-htaccess-ciklicheskaya-pereadresaciya)

##### 1.1.3.1.1. htaccess

```apache
RewriteEngine On
RewriteCond %{SERVER_PORT} !^443$
RewriteRule .* https://%{SERVER_NAME}%{REQUEST_URI} [R=301,L]</pre>
```
или
```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```



### 1.1.4. ZABBIX

#### 1.1.4.1. Установка клиента

> Данная инструкция справедлива для debian, другие ОС смотрите пожалуйста на офф сайте!
[Дополнительные сведения по установке](https://www.zabbix.com/documentation/4.0/ru/manual/installation/install_from_packages/debian_ubuntu)

##### 1.1.4.1.1. Подготовка

 ```bash

 # Проверяем версию дистрибутива linux
 lsb_release -a
  
 # Выбираем русскую локаль для старых версий Debian
 dpkg-reconfigure locales # lang 372 
  
 # или для современных
 localectl set-locale LANG=ru_RU.utf8 
 localectl status
 ```

##### 1.1.4.1.2. Устанавливаем сам агент

```bash
wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bstretch_all.deb
dpkg -i zabbix-release_4.0-2+​stretch_all.deb
apt update
apt-get install zabbix-agent
```

##### 1.1.4.1.3. Правим конфиг агента

 ```bash
# 2. nano /etc/zabbix/zabbix_agent.conf
Server=127.0.0.1, zabbix.filatovz.ru 
ServerActive=zabbix.filatovz.ru 
LogFileSize=10 
LogFile=/var/log/zabbix/zabbix_agentd.log 
PidFile=/run/zabbix/zabbix_agentd.pid 
EnableRemoteCommands=1 
Timeout=30 
Hostname=server_name
 ```

##### 2.0.4.1.4. Добавим zabbix в sudoers

 ```bash
 # nano /etc/sudoers
 zabbix ALL=(ALL) NOPASSWD: ALL
 ```

##### 2.0.4.1.5. Установим zabbix как службу systemd

 `sudo nano /lib/systemd/system/zabbix-agent.service`

 ```ini
 [Unit] 
  
 Description=Zabbix Agent 
 After=syslog.target 
 After=network.target 
  
 [Service] 
  
 Environment="CONFFILE=/etc/zabbix/zabbix_agentd.conf" 
 EnvironmentFile=-/etc/default/zabbix-agent 
 Type=forking 
 Restart=on-failure 
 PIDFile=/run/zabbix/zabbix_agentd.pid
 KillMode=control-group 
 ExecStart=/usr/sbin/zabbix_agentd -c $CONFFILE 
 ExecStop=/bin/kill -SIGTERM $MAINPID 
 RestartSec=10s 
 ```

 `systemctl daemon-reload`

#### 2.0.4.2. Установка сервера

 https://serveradmin.ru/ustanovka-i-nastroyka-zabbix-3-4-na-debian-9/

#### 2.0.4.3. Установка сервера для docker-compose

[Инструкция](https://github.com/zabbix/zabbix-docker)

**Zabbix-postgres docker-compose.yml**

 ```yaml
 version: '3.1' 
 services: 
   postgres: 
     image: postgres 
     restart: always 
     environment: 
       POSTGRES_USER: zabbix 
       POSTGRES_PASSWORD: zabbix 
       POSTGRES_DB: zabbix 
   zabbix-server: 
     image: zabbix/zabbix-server-pgsql 
     restart: always 
     environment: 
       DB_SERVER_HOST: postgres 
       POSTGRES_USER: zabbix 
       POSTGRES_PASSWORD: zabbix 
       POSTGRES_DB: zabbix 
     depends_on: 
       - postgres 
   zabbix-web: 
     image: zabbix/zabbix-web-nginx-pgsql 
     restart: always 
     environment: 
       ZBX_SERVER_HOST: zabbix-server 
       DB_SERVER_HOST: postgres 
       POSTGRES_USER: zabbix 
       POSTGRES_PASSWORD: zabbix 
       POSTGRES_DB: zabbix 
     depends_on: 
       - postgres 
       - zabbix-server 
     ports: 
       - 8080:80 
 ```

### 2.0.5. KODI

[Установка и настройка Quasar на Kodi](https://niklan.net/blog/146)

### 2.0.6. ssh

[Практические советы, примеры и туннели SSH](https://habr.com/ru/post/435546/)

### 2.0.7. PROXMOX

- [virtio-drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

### 2.0.8. WINE
#### 2.0.8.1. Install on Linux Mint 19.3

```bash
sudo dpkg --add-architecture i386
wget -qO- https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
sudo apt-add-repository 'deb http://dl.winehq.org/wine-builds/ubuntu/ bionic main' #(if you bionic error, type `xenial`)
sudo apt-get install --install-recommends winehq-stable
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
# config wine

winetricks --force dotnet452
# for keepass
wget -q -O /tmp/libpng12.deb http://se.archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_i386.deb
dpkg -i /tmp/libpng12.deb
```

## 2.1. OS

Linux команды

## 2.2. HW

[Настройка ИБП](http://geckich.blogspot.com/2012/10/low-battery-ups-nut-network-ups-tools.html)

## 2.3. DevOps

### 2.3.1. Docker

#### 2.3.1.1. Установка Docker + Docker-Compose

```bash
apt update && apt install git curl -y 
git clone https://github.com/docker/docker-install.git 
cd docker-install && sh ./install.sh
curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)"  
chmod +x /usr/local/bin/docker-compose 
docker-compose -v 
systemctl enable docker && systemctl start docker 
mkdir /docker 
cd /docker
```

#### 2.3.1.2. Docker-Compose как systemd сервис

```
/etc/compose/docker-compose.yml - Compose file describing what to deploy 
/etc/systemd/system/docker-compose.service - Service unit to start and manage docker compose 
/etc/systemd/system/docker-compose-reload.service - Executing unit to trigger reload on docker-compose.service
/etc/systemd/system/docker-compose-reload.timer - Timer unit to plan the reloads
```

​	/etc/systemd/system/docker-compose-reload.service

```
[Unit]
 
Description=Refresh images and update containers 
 
[Service] 
 
Type=oneshot 
ExecStart=/bin/systemctl reload docker-compose.service 
 
# /etc/systemd/system/docker-compose-reload.timer
 
[Unit] 
 
Description=Refresh images and update containers 
Requires=docker-compose.service 
After=docker-compose.service 
 
[Timer] 
 
OnCalendar=*:0/15 
 
[Install] 
 
WantedBy=timers.target 
 
# /etc/systemd/system/docker-compose.service
 
[Unit] 
 
Description=Docker Compose container starter 
After=docker.service network-online.target 
Requires=docker.service network-online.target 
 
[Service] 
 
WorkingDirectory=/etc/compose 
Type=oneshot 
RemainAfterExit=yes 
ExecStartPre=/usr/local/bin/docker-compose pull --quiet --parallel 
ExecStart=/usr/local/bin/docker-compose up -d --build 
ExecStop=/usr/local/bin/docker-compose down 
ExecReload=/usr/local/bin/docker-compose pull --quiet --parallel 
ExecReload=/usr/local/bin/docker-compose up -d --build 
 
[Install] 
 
WantedBy=multi-user.target 
 
# systemctl daemon-reload && systemctl enable docker-compose && systemctl start docker-compose 

```



### 2.3.2. Ротация логов

Эта служба необходима для того, чтобы архивировать старые логи или удалять их с какой-то переодичностью.
Базовые настройки хранятся здесь: ''/etc/logrotate.conf''

Пример ротации конкретного файла:

```bash
/var/log/fail2ban.log {

weekly        # ротация раз в неделю. Возможные варианты daily, weekly, monthly, size (например size=1M)
rotate 4      # сохраняется последние 4 ротированных файла
compress      # сжимать ротируемый файл

delaycompress # сжимать предыдущий файл при следующей ротации
missingok     # отсутствие файла не является ошибкой
postrotate    # скрипт будет выполнен сразу после ротации
fail2ban-client set logtarget /var/log/fail2ban.log /dev/null
endscript

# If fail2ban runs as non-root it still needs to have write access
# to logfiles.
# create 640 fail2ban adm 
create 640 root adm # сразу после ротации создать пустой файл с заданными правами и пользователем
} 
```

Для немедленного применения изменений можно выполнить:

```bash
''$ logrotate /etc/logrotate.conf''
```

Для проверки внесенный изменений можно запустить команду (никаких действий с логами не будет выполнено):

```bash
''$ logrotate -d /etc/logrotate.conf''

```

### 2.3.3. Права на файлы

```bash
find /var/www/test.com/public_html -type d -exec chmod 0770 {} \;
find /var/www/test.com/public_html -type f -exec chmod 0660 {} \;
```

## 2.4. DEVELOP

### 2.4.1. PHP

#### 2.4.1.1. Проверка отправки почты через sendmail

```php
[<?php]() 

if (mail("ivan@filatovz1.ru", "заголовок", "текст")) { 
    echo 'Отправлено'; 
} 
else { 
    echo 'Не отправлено'; 
} 

? 
```

### 2.4.2. PYTHON

#### 2.4.2.1. Ссылки

[Мега-Учебник FLASK](https://habr.com/post/346306/)

### 2.4.3. BITRIX
#### 2.4.3.1. Ссылки
[Инструменты для разработки под 1С-Битрикс](https://habr.com/en/sandbox/73214/)