# Public Repo For Sysadmins and other people
<a id="markdown-public-repo-for-sysadmins-and-other-people" name="public-repo-for-sysadmins-and-other-people"></a>
<!-- TOC -->

- [Public Repo For Sysadmins and other people](#public-repo-for-sysadmins-and-other-people)
  - [1. SOFT](#1-soft)
    - [1.1. WINDOWS](#11-windows)
    - [1.2. DUPLICATI](#12-duplicati)
    - [1.3. APACHE](#13-apache)
      - [1.3.1. Различные способы переадрессации](#131-Различные-способы-переадрессации)
        - [1.3.1.1. htaccess](#1311-htaccess)
      - [1.3.2. Анализ Логов](#132-Анализ-Логов)
    - [1.4. ZABBIX](#14-zabbix)
      - [1.4.1. Шаблоны (Templates)](#141-Шаблоны-templates)
      - [1.4.2. Установка клиента](#142-Установка-клиента)
        - [1.4.1.1. Подготовка](#1411-Подготовка)
        - [1.4.1.2. Устанавливаем сам агент](#1412-Устанавливаем-сам-агент)
        - [1.4.1.3. Правим конфиг агента](#1413-Правим-конфиг-агента)
        - [1. Добавим zabbix в sudoers](#1-Добавим-zabbix-в-sudoers)
        - [2. Установим zabbix как службу systemd](#2-Установим-zabbix-как-службу-systemd)
      - [1. Установка сервера](#1-Установка-сервера)
      - [2. Установка сервера для docker-compose](#2-Установка-сервера-для-docker-compose)
    - [1.5. KODI](#15-kodi)
    - [1.6. ssh](#16-ssh)
    - [1.7. PROXMOX](#17-proxmox)
    - [1.8. WINE](#18-wine)
      - [1.8.1. Install on Linux Mint 19.3](#181-install-on-linux-mint-193)
  - [2. OS](#2-os)
    - [2.1. Linux команды](#21-linux-команды)
    - [2.2. Journalctl - дистрибутивы с systemd](#22-journalctl---дистрибутивы-с-systemd)
  - [3. DEVOPS](#3-devops)
    - [3.1. Docker](#31-docker)
      - [3.1.1. Установка Docker + Docker-Compose](#311-Установка-docker--docker-compose)
      - [3.1.2. Docker-Compose как systemd сервис](#312-docker-compose-как-systemd-сервис)
    - [3.2. Ротация логов](#32-Ротация-логов)
    - [3.3. Права на файлы](#33-Права-на-файлы)
  - [4. DEVELOP](#4-develop)
    - [4.1. PHP](#41-php)
      - [4.1.1. Проверка отправки почты через sendmail](#411-Проверка-отправки-почты-через-sendmail)
    - [4.2. PYTHON](#42-python)
      - [4.2.1. Ссылки](#421-Ссылки)
    - [4.3. BITRIX](#43-bitrix)
      - [4.3.1. Ссылки](#431-Ссылки)
  - [5. Написание документации](#5-Написание-документации)
    - [5.1. Софт + плагины](#51-Софт--плагины)
      - [5.1.1. Visual Studio Code](#511-visual-studio-code)

<!-- /TOC -->


## 1. SOFT
<a id="markdown-soft" name="soft"></a>

### 1.1. WINDOWS
<a id="markdown-windows" name="windows"></a>

- [Узнать размер папок (Scanner)](http://www.steffengerlach.de/freeware/scn2.zip)

### 1.2. DUPLICATI
<a id="markdown-duplicati" name="duplicati"></a>

[Статья по установке](https://www.techgrube.de/tutorials/homeserver-nas-mit-ubuntu-18-04-teil-7-backups-mit-duplicati-und-rsnapshot)

### 1.3. APACHE
<a id="markdown-apache" name="apache"></a>

#### 1.3.1. Различные способы переадрессации
<a id="markdown-различные-способы-переадрессации" name="различные-способы-переадрессации"></a>

[Источник](https://afirewall.ru/redirekt-s-http-na-https-htaccess-ciklicheskaya-pereadresaciya)

##### 1.3.1.1. htaccess

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

#### 1.3.2. Анализ Логов
<a id="markdown-анализ-логов" name="анализ-логов"></a>

```bash
cat /var/log/apache2/access.log | cut -d " " -f 1 | sort | uniq -c | sort -n -r | head -n 10
zcat /var/log/apache2/access.log.*.gz | cut -d " " -f 1 | sort | uniq -c | sort -n -r | head -n 10
```

### 1.4. ZABBIX
<a id="markdown-zabbix" name="zabbix"></a>

- [Обновление zabbix до 4.4 (debian)](https://www.zabbix.com/documentation/current/ru/manual/installation/upgrade/packages/debian_ubuntu)

#### 1.4.1. Шаблоны (Templates)
<a id="markdown-шаблоны-templates" name="шаблоны-templates"></a>
- Веб-сервер | [инструкция](https://serveradmin.ru/monitoring-web-servera-nginx-i-php-fpm-v-zabbix/#_nginx) | [шаблон](./SOFT/zabbix/zabbix-nginx-template.xml)
- ssh-auth | [инструкция](https://serveradmin.ru/monitoring-ssh-loginov-v-zabbix/#__SSH) | [шаблон](./SOFT/zabbix/ssh-auth.xml)

#### 1.4.2. Установка клиента
<a id="markdown-установка-клиента" name="установка-клиента"></a>

> Данная инструкция справедлива для debian, другие ОС смотрите пожалуйста на офф сайте!
[Дополнительные сведения по установке](https://www.zabbix.com/documentation/4.0/ru/manual/installation/install_from_packages/debian_ubuntu)

##### 1.4.1.1. Подготовка

 ```bash

 # Проверяем версию дистрибутива linux
 lsb_release -a
  
 # Выбираем русскую локаль для старых версий Debian
 dpkg-reconfigure locales # lang 372 
  
 # или для современных
 localectl set-locale LANG=ru_RU.utf8 
 localectl status
 ```

##### 1.4.1.2. Устанавливаем сам агент

```bash
wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-2%2Bstretch_all.deb
dpkg -i zabbix-release_4.0-2+​stretch_all.deb
apt update
apt-get install zabbix-agent
```

##### 1.4.1.3. Правим конфиг агента

 ```bash

# nano /etc/zabbix/zabbix_agent.conf
<a id="markdown-nano-etczabbixzabbixagentconf" name="nano-etczabbixzabbixagentconf"></a>
Server=127.0.0.1, zabbix.filatovz.ru 
ServerActive=zabbix.filatovz.ru 
LogFileSize=10 
LogFile=/var/log/zabbix/zabbix_agentd.log 
PidFile=/run/zabbix/zabbix_agentd.pid 
EnableRemoteCommands=1 
Timeout=30 
Hostname=server_name
 ```

##### 1. Добавим zabbix в sudoers

 ```bash
 # nano /etc/sudoers
 zabbix ALL=(ALL) NOPASSWD: ALL
 ```

##### 2. Установим zabbix как службу systemd

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

#### 1. Установка сервера
<a id="markdown-установка-сервера" name="установка-сервера"></a>

 https://serveradmin.ru/ustanovka-i-nastroyka-zabbix-3-4-na-debian-9/

#### 2. Установка сервера для docker-compose
<a id="markdown-установка-сервера-для-docker-compose" name="установка-сервера-для-docker-compose"></a>

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

### 1.5. KODI
<a id="markdown-kodi" name="kodi"></a>

[Установка и настройка Quasar на Kodi](https://niklan.net/blog/146)

### 1.6. ssh
<a id="markdown-ssh" name="ssh"></a>

[Практические советы, примеры и туннели SSH](https://habr.com/ru/post/435546/)

### 1.7. PROXMOX
<a id="markdown-proxmox" name="proxmox"></a>

- [virtio-drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

### 1.8. WINE
<a id="markdown-wine" name="wine"></a>

#### 1.8.1. Install on Linux Mint 19.3
<a id="markdown-install-on-linux-mint-193" name="install-on-linux-mint-193"></a>

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

## 2. OS
<a id="markdown-os" name="os"></a>

### 2.1. Linux команды
<a id="markdown-linux-команды" name="linux-команды"></a>

- [Настройка ИБП](http://geckich.blogspot.com/2012/10/low-battery-ups-nut-network-ups-tools.html)

### 2.2. Journalctl - дистрибутивы с systemd
<a id="markdown-journalctl---дистрибутивы-с-systemd" name="journalctl---дистрибутивы-с-systemd"></a>

```bash
# Показать ошибки
journalctl -p err

# Показать логи в реальном времени
journalctl -f

# Логи за определенную дату
journalctl --since=2016-12-20
journalctl --since=2016-12-20 --until=2016-12-21

# Лог конкретного сервиса
journalctl -b -u zabbix-agent.service

```

## 3. DEVOPS
<a id="markdown-devops" name="devops"></a>

### 3.1. Docker
<a id="markdown-docker" name="docker"></a>

#### 3.1.1. Установка Docker + Docker-Compose
<a id="markdown-установка-docker--docker-compose" name="установка-docker--docker-compose"></a>

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

#### 3.1.2. Docker-Compose как systemd сервис
<a id="markdown-docker-compose-как-systemd-сервис" name="docker-compose-как-systemd-сервис"></a>

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



### 3.2. Ротация логов
<a id="markdown-ротация-логов" name="ротация-логов"></a>

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

### 3.3. Права на файлы
<a id="markdown-права-на-файлы" name="права-на-файлы"></a>

```bash
find /var/www/test.com/public_html -type d -exec chmod 0770 {} \;
find /var/www/test.com/public_html -type f -exec chmod 0660 {} \;
```

## 4. DEVELOP
<a id="markdown-develop" name="develop"></a>

### 4.1. PHP
<a id="markdown-php" name="php"></a>

#### 4.1.1. Проверка отправки почты через sendmail
<a id="markdown-проверка-отправки-почты-через-sendmail" name="проверка-отправки-почты-через-sendmail"></a>

```php
<?php

if (mail("ivan@filatovz1.ru", "заголовок", "текст")) { 
    echo 'Отправлено'; 
} 
else { 
    echo 'Не отправлено'; 
} 

?>
```

### 4.2. PYTHON
<a id="markdown-python" name="python"></a>

#### 4.2.1. Ссылки
<a id="markdown-ссылки" name="ссылки"></a>

[Мега-Учебник FLASK](https://habr.com/post/346306/)

### 4.3. BITRIX
<a id="markdown-bitrix" name="bitrix"></a>

#### 4.3.1. Ссылки
<a id="markdown-ссылки" name="ссылки"></a>
[Инструменты для разработки под 1С-Битрикс](https://habr.com/en/sandbox/73214/)

## 5. Написание документации
<a id="markdown-написание-документации" name="написание-документации"></a>

### 5.1. Софт + плагины
<a id="markdown-софт--плагины" name="софт--плагины"></a>

#### 5.1.1. Visual Studio Code
<a id="markdown-visual-studio-code" name="visual-studio-code"></a>
- [Auto MarkdownTOC](https://github.com/huntertran/markdown-toc)
- [Markdown All in One](https://github.com/yzhang-gh/vscode-markdown)