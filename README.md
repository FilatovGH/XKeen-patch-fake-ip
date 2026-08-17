# XKeen-patch-fake-ip

Убирает `198.18.0.0/15` из `ipv4_exclude` в `/opt/etc/init.d/S05xkeen`, чтобы fake-ip диапазон mihomo не исключался из перехвата.

## Проблема

XKeen исключает `198.18.0.0/15` из проксирования. Mihomo в режиме fake-ip по умолчанию раздаёт адреса из этого же диапазона. Правило `RETURN` срабатывает раньше перехвата, пакет уходит в дефолтный маршрут — соединение висит до таймаута без ошибки.

## Запуск

```sh
BASE=https://raw.githubusercontent.com/FilatovGH/XKeen-patch-fake-ip/main/xkeen-fakeip-patch.sh

curl -fsSL $BASE | sh                 # apply
curl -fsSL $BASE | sh -s -- revert    # откат
```

Аргумент передаётся только через `sh -s --`. Без аргумента выполняется `apply`.

## Что делает

`apply` — бэкап в `S05xkeen.bak`, удаление подсети из строк `ipv4_exclude`, `xkeen -restart`, проверка что правил с `198.18.*` в цепочке `xkeen` не осталось.

`revert` — восстановление из бэкапа с проверкой, что он снят с непропатченного файла.

## После обновления XKeen

`opkg upgrade xkeen` перезаписывает `S05xkeen`, патч слетает молча. Запускать `apply` заново.

```sh
grep -c '198\.18\.0\.0/15' /opt/etc/init.d/S05xkeen   # 0 = патч на месте
```
