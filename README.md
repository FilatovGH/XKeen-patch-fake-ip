# XKeen-patch-fake-ip

Убирает `198.18.0.0/15` из `ipv4_exclude` в `/opt/etc/init.d/S05xkeen`, чтобы fake-ip диапазон mihomo не исключался из перехвата.

## Проблема

XKeen исключает `198.18.0.0/15` из проксирования. Mihomo в режиме fake-ip по умолчанию раздаёт адреса из этого же диапазона. Правило `RETURN` срабатывает раньше перехвата, пакет уходит в дефолтный маршрут — соединение висит до таймаута без ошибки.

## Запуск

Применить:

```sh
curl -fsSL https://raw.githubusercontent.com/FilatovGH/XKeen-patch-fake-ip/main/xkeen-fakeip-patch.sh | sh
```

Откатить:

```sh
curl -fsSL https://raw.githubusercontent.com/FilatovGH/XKeen-patch-fake-ip/main/xkeen-fakeip-patch.sh | sh -s -- revert
```

## После обновления XKeen

После обновления XKeen перезаписывает `S05xkeen`, патч слетает. Требуется применить заново.

```sh
grep -c '198\.18\.0\.0/15' /opt/etc/init.d/S05xkeen   # 0 = патч на месте
```
