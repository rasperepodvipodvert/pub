# PUB
Public Repo For Sysadmins and other people

Сначала вел документацию на WIKI (dockuwiki) сейчас же перешел на GitHUB.

[TOC]



## SOFT

### ZABBIX

#### Установка клиента

> Данная инструкция справедлива для debian, другие ОС смотрите пожалуйста на офф сайте!
[Дополнительные сведения по установке](https://www.zabbix.com/documentation/4.0/ru/manual/installation/install_from_packages/debian_ubuntu)

##### Подготовка

 ```bash

 # Проверяем версию дистрибутива linux
 lsb_release -a
  
 # Выбираем русскую локаль для старых версий Debian
 dpkg-reconfigure locales # lang 372 
  
 # или для современных
 localectl set-locale LANG=ru_RU.utf8 
 localectl status
 ```

##### Устанавливаем сам агент

```bash
wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-2+​stretch_all.deb
dpkg -i zabbix-release_4.0-2+​stretch_all.deb
apt update
apt-get install zabbix-agent
```

##### Правим конфиг агента

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

#####  Добавим zabbix в sudoers

 ```bash
 # nano /etc/sudoers
 zabbix ALL=(ALL) NOPASSWD: ALL
 ```

 Установим zabbix как службу systemd

 `sudo nano /lib/systemd/system/zabbix-agent.service`

 ```bash
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

#### Установка сервера zabbix

 https://serveradmin.ru/ustanovka-i-nastroyka-zabbix-3-4-na-debian-9/

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

 

#### zabbix docker-compose

Инструкция

https://github.com/zabbix/zabbix-docker

## OS

### KODI

[Установка и настройка Quasar на Kodi](https://niklan.net/blog/146)

### ssh

[Практические советы, примеры и туннели SSH](https://habr.com/ru/post/435546/)

## HW

[Настройка ИБП](http://geckich.blogspot.com/2012/10/low-battery-ups-nut-network-ups-tools.html)

## DevOps

### Docker

#### Установка Docker + Docker-Compose

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

#### Docker-Compose как systemd сервис

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



### Ротация логов

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

### Права на файлы

```bash
find /var/www/test.com/public_html -type d -exec chmod 0770 {} \;
find /var/www/test.com/public_html -type f -exec chmod 0660 {} \;
```

## DEVELOP

### PHP

#### Проверка отправки почты через sendmail

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

### PYTHON

#### Ссылки

[Мега-Учебник FLASK](https://habr.com/post/346306/)

