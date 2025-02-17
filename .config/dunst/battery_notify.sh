#!/bin/bash

# Экспорт переменных окружения (для cron)
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Пороги для уведомлений
LOW_BATTERY_THRESHOLD_1=20  # Первое предупреждение
LOW_BATTERY_THRESHOLD_2=5   # Второе предупреждение

# Файл для хранения последнего уровня заряда
STATE_FILE="/tmp/battery_notify_state"

# Получаем данные о батарее
BATTERY_INFO=$(acpi -b 2>/dev/null)

# Логирование
log_file="/tmp/battery_notify.log"
echo "[$(date)] Запуск скрипта" >> "$log_file"

# Проверка наличия данных
if [[ -z "$BATTERY_INFO" ]]; then
    echo "[$(date)] Ошибка: Нет данных о батарее" >> "$log_file"
    exit 1
fi

# Парсим уровень и статус
BATTERY_LEVEL=$(echo "$BATTERY_INFO" | grep -P -o '[0-9]+(?=%)' | head -n 1)
BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep -o "Discharging")

echo "[$(date)] Уровень: $BATTERY_LEVEL%, Статус: $BATTERY_STATUS" >> "$log_file"

# Читаем последний уровень заряда из файла
if [[ -f "$STATE_FILE" ]]; then
    LAST_NOTIFIED_LEVEL=$(cat "$STATE_FILE")
else
    LAST_NOTIFIED_LEVEL=100  # По умолчанию (если файла нет)
fi

# Проверка условий для первого порога (20%)
if [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD_1" && "$LAST_NOTIFIED_LEVEL" -gt "$LOW_BATTERY_THRESHOLD_1" ]]; then
    echo "[$(date)] Отправка уведомления на 20%..." >> "$log_file"
    /usr/bin/notify-send -u critical -a "battery_notify" "Низкий заряд батареи" "Уровень: $BATTERY_LEVEL%"
    echo "$BATTERY_LEVEL" > "$STATE_FILE"  # Сохраняем уровень заряда
fi

# Проверка условий для второго порога (5%)
if [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD_2" && "$LAST_NOTIFIED_LEVEL" -gt "$LOW_BATTERY_THRESHOLD_2" ]]; then
    echo "[$(date)] Отправка уведомления на 5%..." >> "$log_file"
    /usr/bin/notify-send -u critical -a "battery_notify" "Критический заряд батареи" "Уровень: $BATTERY_LEVEL%"
    echo "$BATTERY_LEVEL" > "$STATE_FILE"  # Сохраняем уровень заряда
fi
