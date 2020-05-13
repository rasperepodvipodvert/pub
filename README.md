# Public Repo For Sysadmins and other people

<!-- TOC -->

- [Public Repo For Sysadmins and other people](#public-repo-for-sysadmins-and-other-people)
  - [1. SOFT](#1-soft)
    - [1.1. WINDOWS](#11-windows)
    - [1.2. DUPLICATI](#12-duplicati)
      - [1.2.1. Резервное копирование Bitrix CMS](#121-Резервное-копирование-bitrix-cms)
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
    - [1.9. Docker](#19-docker)
  - [2. OS](#2-os)
    - [2.1. Linux команды](#21-linux-команды)
      - [2.1.1. Journalctl - дистрибутивы с systemd](#211-journalctl---дистрибутивы-с-systemd)
      - [2.1.2. contains a file system with errors check forced](#212-contains-a-file-system-with-errors-check-forced)
      - [2.1.3. Включаем SWAP в файле](#213-Включаем-swap-в-файле)
      - [2.1.4. Выключаем IPv6 (debian)](#214-Выключаем-ipv6-debian)
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
      - [4.3.1. Очистка кэша](#431-Очистка-кэша)
      - [4.3.2. Ссылки](#432-Ссылки)
      - [4.3.3. Backup](#433-backup)
  - [5. Написание документации](#5-Написание-документации)
    - [5.1. Софт + плагины](#51-Софт--плагины)
      - [5.1.1. Visual Studio Code](#511-visual-studio-code)

<!-- /TOC -->

## 1. SOFT


### 1.1. WINDOWS


- [Узнать размер папок (Scanner)](http://www.steffengerlach.de/freeware/scn2.zip)

### 1.2. DUPLICATI

#### 1.2.1. Резервное копирование Bitrix CMS

**Задача:** Осуществлять резервное копирование Bitrix CMS максимально удобным способом. Желательно тиметь инкрементарные копии.

**Имеем:** 

- 100+ сайтов с битриксом на 10 VPS под Docker. Да, сайты на битриксе работают на нашем собственном стеке MSQL+NGINX+APACHE. Каждый сайт изолирован друг от друга отдельным контейнером со своим апачем.
- Общий обьем данных 1,5 ТБ
- Облако Selectel для хранения бэкапов (обьектное хранилище)

**Что пробовал:**

- Veeam Agent Free. Умеет делать копии и отправлять их по SAMBA или NFS, не умеет отправлять сам в облака, не умеет делать дамп mysql, при подключении облачных провайдеров становится очень дорогим решением)
- Dupliciti. Ввиду разной версии Linux установленной на хостовых машинах, с этим программным обеспечением возникли трудности. Допиливание install.ansbl.yml для установки dupliciti под старые версии дистрибутивов стали занимать очень много времени и постоянно появлялись те или иные ошибки, вообщем не пошло. Да, были и ubuntu 12.04 и debian6.
- Ansible. После разочарования с veam решил написать свой алгоритм действий с помощью ansible и столкнулся с нерешенной [ошибкой](https://github.com/ansible/ansible/issues/42090) в модуле archive (если кратко - оно не обрабатывает симлинки и крашится...). Так же отсуствие возможности инкрементарных копий поставило крест на данном способе резервного копирования.
- [Duplicati в Docker](https://hub.docker.com/r/linuxserver/duplicati/). На этом варианте я и остановился! Умеет инкрементарные копии, exclude не нужных данных, умеет exclude по фильтрам маскам, может заливать в s3,Swift,ftp,sftp,Google,Yandex,MailRu..., умеет шифровать все это дело и ставится одной командой. Конечно же я интегрировал его в стек благо есть простой [docker-compose.yml](./docker/duplicati/docker-compose.yml)

**Установка:**

- Сохраняем у себя [docker-compose.yml](./docker/duplicati/docker-compose.yml)
- Запускаем из директории где лежит [docker-compose.yml](./docker/duplicati/docker-compose.yml) (docker и docker-compose должен быть уже установлен):
  ```bash
  docker-compose up -d
  ```
- Добавил [Dockerfile](./Dockerfile) для внесения изменений в стандартный [image](https://hub.docker.com/r/linuxserver/duplicati) Duplicati. Теперь можно еще и MysqlDump делать прямо из Duplicati

### 1.3. APACHE


#### 1.3.1. Различные способы переадрессации


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


```bash
cat /var/log/apache2/access.log | cut -d " " -f 1 | sort | uniq -c | sort -n -r | head -n 10
zcat /var/log/apache2/access.log.*.gz | cut -d " " -f 1 | sort | uniq -c | sort -n -r | head -n 10
```

### 1.4. ZABBIX


- [Обновление zabbix до 4.4 (debian)](https://www.zabbix.com/documentation/current/ru/manual/installation/upgrade/packages/debian_ubuntu)

#### 1.4.1. Шаблоны (Templates)


- Веб-сервер | [инструкция](https://serveradmin.ru/monitoring-web-servera-nginx-i-php-fpm-v-zabbix/#_nginx) | [шаблон](./SOFT/zabbix/zabbix-nginx-template.xml)
- ssh-auth | [инструкция](https://serveradmin.ru/monitoring-ssh-loginov-v-zabbix/#__SSH) | [шаблон](./SOFT/zabbix/ssh-auth.xml)
- fail2ban | [git](https://github.com/rasperepodvipodvert/zabbix-fail2ban-discovery-)

#### 1.4.2. Установка клиента


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


 https://serveradmin.ru/ustanovka-i-nastroyka-zabbix-3-4-na-debian-9/

#### 2. Установка сервера для docker-compose


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


[Установка и настройка Quasar на Kodi](https://niklan.net/blog/146)

### 1.6. ssh


[Практические советы, примеры и туннели SSH](https://habr.com/ru/post/435546/)

### 1.7. PROXMOX


- [virtio-drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

### 1.8. WINE


#### 1.8.1. Install on Linux Mint 19.3


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

### 1.9. Docker

```shell script
docker system df                      # использование диска Docker’ом в различных разрезах
```



## 2. OS


### 2.1. Linux команды



- [Настройка ИБП](http://geckich.blogspot.com/2012/10/low-battery-ups-nut-network-ups-tools.html)

#### 2.1.1. Journalctl - дистрибутивы с systemd


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

#### 2.1.2. contains a file system with errors check forced

```shell script
fsck -y /dev/sda1 ; reboot -f
```

#### 2.1.3. Включаем SWAP в файле

```shell script
sudo dd if=/dev/zero of=/var/swapfile bs=1M count=2048
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
echo /var/swapfile none swap defaults 0 0 | sudo tee -a /etc/fstab
sudo swapon -a

```

#### 2.1.4. Выключаем IPv6 (debian)
```
$ sudo nano /etc/sysctl.conf

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```



## 3. DEVOPS


### 3.1. Docker


#### 3.1.1. Установка Docker + Docker-Compose


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


```systemd
/etc/compose/docker-compose.yml - Compose file describing what to deploy 
/etc/systemd/system/docker-compose.service - Service unit to start and manage docker compose 
/etc/systemd/system/docker-compose-reload.service - Executing unit to trigger reload on docker-compose.service
/etc/systemd/system/docker-compose-reload.timer - Timer unit to plan the reloads
```

/etc/systemd/system/docker-compose-reload.service

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


```bash
find /var/www/test.com/public_html -type d -exec chmod 0770 {} \;
find /var/www/test.com/public_html -type f -exec chmod 0660 {} \;
```

## 4. DEVELOP


### 4.1. PHP


#### 4.1.1. Проверка отправки почты через sendmail


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


#### 4.2.1. Ссылки


[Мега-Учебник FLASK](https://habr.com/post/346306/)

### 4.3. BITRIX

#### 4.3.1. Очистка кэша
```shell script
rm -rf ./bitrix/upload/resize_cache # Просто удаляете эту папку и битрикс потом сам пересоздаст кэш по мере потребления (https://qna.habr.com/q/564222)
# Можно еще правильно настроить битрикс (https://iplogic.ru/baza-znaniy/ochistka-papki-upload-v-bitriks-cherez-agent/)
```

#### 4.3.2. Ссылки

[Инструменты для разработки под 1С-Битрикс](https://habr.com/en/sandbox/73214/)

#### 4.3.3. Backup
- [Детальное описание](https://tuning-soft.ru/articles/bitrix/backup-bitrix.html)

```ini
# exlude directory for bitrix < v12
/bitrix/backup
/bitrix/cache
/bitrix/managed_cache
/bitrix/stack_cache
/upload/resize_cache

```



## 5. Написание документации


### 5.1. Софт + плагины


#### 5.1.1. Visual Studio Code


- [Auto MarkdownTOC](https://github.com/huntertran/markdown-toc)
- [Markdown All in One](https://github.com/yzhang-gh/vscode-markdown)