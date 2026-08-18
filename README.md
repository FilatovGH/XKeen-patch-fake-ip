# XKeen-patch-fake-ip

## Проблема

XKeen исключает `198.18.0.0/15` из проксирования. Mihomo в режиме fake-ip по умолчанию раздаёт адреса из этого же диапазона. Правило `RETURN` срабатывает раньше перехвата, пакет уходит в дефолтный маршрут — соединение висит до таймаута без ошибки.

## Что делает скрипт

Скрипт удаляет `198.18.0.0/15` из `ipv4_exclude` в `S05xkeen`, включает DNS Override (`opkg dns-override`), перезапускает XKeen и сохраняет конфигурацию. Перед изменением создаёт бэкап файла.

Откат — восстанавливает файл из бэкапа, выключает DNS Override, перезапускает XKeen и сохраняет конфигурацию.

Каждый шаг проверяется: подсеть действительно удалена/восстановлена, XKeen перезапущен, DNS Override переключён, правил `198.18.*` в цепочке `xkeen` нет (apply) или они на месте (revert).

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
