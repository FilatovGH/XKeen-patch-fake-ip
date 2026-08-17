#!/bin/sh
# XKeen: убрать/вернуть 198.18.0.0/15 в ipv4_exclude
# curl -fsSL <url> | sh -s -- apply
# curl -fsSL <url> | sh -s -- revert

F=/opt/etc/init.d/S05xkeen
B=$F.bak
N='198\.18\.0\.0/15'
A=${1:-apply}
CUR=старт

trap 'echo; echo "[!] ПРЕРВАНО на: $CUR"; exit 130' INT TERM
say()  { CUR="$1"; echo "[*] $1"; }
fail() { echo "[!] СБОЙ на: $CUR — $1"; exit 1; }
cnt()  { echo $(( $(iptables -t nat -L xkeen -n 2>/dev/null | grep -c 198.18) \
                + $(iptables -t mangle -L xkeen -n 2>/dev/null | grep -c 198.18) )); }

case "$A" in
apply)
  say "бэкап в $B"
  [ -f "$B" ] || cp -p "$F" "$B" || fail "cp"
  say "удаление 198.18.0.0/15 из ipv4_exclude"
  sed -i "/ipv4_exclude/ s| *$N||g" "$F" || fail "sed" ;;
revert)
  say "восстановление из $B"
  [ -f "$B" ] || fail "бэкап не найден"
  cp -p "$B" "$F" || fail "cp" ;;
*) echo "usage: sh -s -- apply|revert"; exit 1 ;;
esac

say "перезапуск XKeen"
xkeen -restart >/dev/null 2>&1 || fail "xkeen -restart вернул ошибку"

say "проверка"
grep -n ipv4_exclude "$F"
C=$(cnt); echo "[*] правил 198.18.* в цепочке xkeen: $C"
case "$A:$C" in
  apply:0)  echo "[OK] патч применён" ;;
  apply:*)  fail "правила остались ($C)" ;;
  revert:0) fail "правила не вернулись" ;;
  *)        echo "[OK] откат выполнен" ;;
esac
