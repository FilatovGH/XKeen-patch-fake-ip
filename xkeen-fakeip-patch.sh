#!/bin/sh
# XKeen: убрать/вернуть 198.18.0.0/15 в ipv4_exclude
#   curl -fsSL <url> | sh              # apply
#   curl -fsSL <url> | sh -s -- revert # откат
# Патч слетает при opkg upgrade xkeen — запускать apply заново.

F=/opt/etc/init.d/S05xkeen
B=$F.bak
N='198\.18\.0\.0/15'
A=${1:-apply}
CUR=старт

trap 'echo; echo "  ПРЕРВАНО: $CUR"; exit 130' INT TERM
step() { CUR="$1"; printf '  [%s/5] %-34s' "$2" "$1"; }
ok()   { echo "ok"; }
fail() { echo "СБОЙ"; echo "  причина: $1"; exit 1; }
has()  { grep 'ipv4_exclude=' "$F" | grep -q "$N"; }
cnt()  { echo $(( $(iptables -t nat -L xkeen -n 2>/dev/null | grep -c 198.18) \
                + $(iptables -t mangle -L xkeen -n 2>/dev/null | grep -c 198.18) )); }

case "$A" in
  apply)  echo; echo "  ПРИМЕНЕНИЕ ПАТЧА" ;;
  revert) echo; echo "  ОТКАТ ПАТЧА" ;;
  *) echo "usage: sh -s -- apply|revert"; exit 1 ;;
esac
echo

step "проверка файла" 1
[ -f "$F" ] || fail "$F не найден"
ok

if [ "$A" = apply ]; then
  step "резервная копия" 2
  if [ -f "$B" ]; then echo "уже есть"
  else cp -p "$F" "$B" || fail "cp"; ok; fi

  step "удаление подсети" 3
  has || { echo "не требуется"; echo; echo "  патч уже применён"; exit 0; }
  sed -i "/ipv4_exclude=/ s| *$N||g" "$F" || fail "sed"
  has && fail "подсеть осталась, формат строки изменился"
  ok
else
  step "проверка бэкапа" 2
  [ -f "$B" ] || fail "$B не найден"
  grep 'ipv4_exclude=' "$B" | grep -q "$N" || fail "бэкап снят с пропатченного файла"
  ok

  step "восстановление" 3
  cp -p "$B" "$F" || fail "cp"
  ok
fi

step "перезапуск XKeen" 4
xkeen -restart >/dev/null 2>&1 || fail "xkeen -restart вернул ошибку"
ok

step "проверка правил" 5
iptables -t nat -L xkeen -n >/dev/null 2>&1 || fail "цепочка xkeen не создана"
C=$(cnt)
case "$A:$C" in
  apply:0)  ok; echo; echo "  ГОТОВО — правил 198.18.* в цепочке xkeen: 0" ;;
  apply:*)  fail "правила остались ($C)" ;;
  revert:0) fail "правила не вернулись" ;;
  *)        ok; echo; echo "  ГОТОВО — правил 198.18.* в цепочке xkeen: $C" ;;
esac
