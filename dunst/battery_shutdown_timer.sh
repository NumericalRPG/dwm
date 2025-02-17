#!/bin/bash

# Порог низкого уровня батареи (в %)
LOW_BATTERY_THRESHOLD=3

# Время до отключения (в секундах)
SHUTDOWN_TIMER=60

# Получаем уровень заряда батареи
BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')

# Проверяем, подключена ли батарея
BATTERY_STATUS=$(acpi -b | grep -o "Discharging")

# Если батарея разряжается и уровень ниже порога
if [[ "$BATTERY_STATUS" == "Discharging" && "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ]]; then
    # Отправляем уведомление с таймером
    notify-send -u critical -a "battery_notify" "Критический заряд батареи" "Ноутбук отключится через $SHUTDOWN_TIMER секунд!"

    # Воспроизводим звуковое предупреждение
    aplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga

    # Обратный отсчёт
    for ((i=SHUTDOWN_TIMER; i>=0; i--)); do
        # Обновляем уведомление
        notify-send -u critical -a "battery_notify" "Критический заряд батареи" "Ноутбук отключится через $i секунд!" -t 1000

        # Воспроизводим звук каждые 10 секунд
        if ((i % 10 == 0)); then
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
        fi

        sleep 1
    done

    sudo shutdown now

fi
