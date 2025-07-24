# Быстрая установка Supabase на VDS/VPS (Ubuntu 22.04 или 24.04)
Автоматическая установка Supabase на VDS/VPS (Ubuntu 22.04 или 24.04) с привязкой домена и авторизацией + Nginx + SSL.

**Автор:** [@lexinthai ](AlexGreen)
---
## Шаг 1: Регистрируем сервер ( у меня - Beget)

1. Перейдите по ссылке: [https://beget.com/p2407726/ru/cloud](https://beget.com/p2407726/ru/cloud)
2. Выберите тариф желательно от 2 GB RAM
3. Сделайте настройки:

   * Операционная система: `Ubuntu 22.04` либо `Ubuntu 24.04`
   * Придумайте хороший сложный пароль root (запишите, сохраните)
   * Задайте имя сервера (например `Supabase`)

------------------------------------
## Шаг 2: Подключение домена

1. Зарегистрируйте домен (если его ещё нет) либо к ужезарегистрированному добавьте  А-запись
2. В DNS-записях создай `A`-запись c IP-адресом Вашего сервера
------------------------------------

## Шаг 3: Устанавливаем Supabase

Введи в терминале следующую команду:

```bash
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/install.sh)
```

Прграмма последовательно установит все необходимое:

* Docker и docker-compose
* Supabase self-hosted (через Supabase CLI и `supabase start`)
* Nginx с SSL (Let's Encrypt) и Basic Auth (логин/пароль для доступа к Supabase Studio)
* Запросит домен и подставит его в nginx
* Полезные утилиты: `git`, `jq`, `htop`, `net-tools`, `ufw`, `unzip`

------------------------------------

## В установку включено:

* Supabase (PostgreSQL, API, Studio, Auth, Storage и прочие сервисы)
* Basic Auth (защита по логину/паролю для Supabase Studio)
* HTTPS с автоматическим сертификатом от Let's Encrypt
* Хранение данных в `/opt/supabase-project`

------------------------------------

## Обновление Supabase

Запустите обновление командой:

```bash
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/update.sh)
```

### Что делает `update.sh`:

* 1. Создаст резервную копию перед обновлением
* 2. Перезапустит Supabase с новыми Docker образами

------------------------------------

## Резервная копия базы данных

Ручной бэкап:

```bash
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/backup.sh)
```

Автоматический бэкап в `cron`:

```cron
0 2 * * * /bin/bash /opt/supabase-project/backup.sh
```

------------------------------------

## Быстрый запуск скриптов

```bash
# Установка Supabase
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/install.sh)

# Безопасное обновление Supabase
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/update.sh)

# Резервное копирование базы данных
bash <(curl -s https://raw.githubusercontent.com/lexinthai/Supabase_on_VPS/main/backup.sh)
```

------------------------------------

## Скрипты в репозитории

| Скрипт                                                                                   | Назначение           |
| ---------------------------------------------------------------------------------------- | -------------------- |
| [`install.sh`](https://github.com/lexinthai/Supabase_on_VPS/blob/main/install.sh) | Установка Supabase   |
| [`update.sh`](https://github.com/lexinthai/Supabase_on_VPS/blob/main/update.sh)   | Обновление с бэкапом |
