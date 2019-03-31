# PUB
Public Repo For Sysadmins and other people

Сначала вел документацию на WIKI (dockuwiki) сейчас же перешел на GitHUB.

[TOC]



## SOFT

## OS

## HW

[Настройка ИБП](http://geckich.blogspot.com/2012/10/low-battery-ups-nut-network-ups-tools.html)

## DevOps

### Ротация логов

> Эта служба необходима для того, чтобы архивировать старые логи или удалять их с какой-то переодичностью.
> Базовые настройки хранятся здесь: ''/etc/logrotate.conf''

Пример ротации конкретного файла:

```bash
/var/log/fail2ban.log {

weekly        # ротация раз в неделю. Возможные варианты daily, weekly, monthly, size (например size=1M)
rotate 4      # сохраняется последние 4 ротированных файла
compress      # сжимать ротируемый файл

delaycompress # сжимать предыдущий файл при следующей ротации
missingok     # отсутствие файла не является ошибкой
postrotate    # скрипт будет выполнен сразу после ротации
fail2ban-client set logtarget /var/log/fail2ban.log >/dev/null
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

