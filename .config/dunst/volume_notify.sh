#!/bin/bash

# Получаем текущий уровень громкости
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n 1)

# Проверяем, включен ли звук
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)')

case $1 in
    up)
        # Увеличиваем громкость
        amixer set Master 5%+
        ;;
    down)
        # Уменьшаем громкость
        amixer set Master 5%-
        ;;
    mute)
        # Переключаем режим "mute"
        amixerl set Master toggle
        ;;
esac

# Обновляем значение громкости после изменения
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n 1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)')

# Иконка для уведомления
if [[ $MUTE == "yes" ]]; then
    ICON="audio-volume-muted"
    MESSAGE="Звук выключен"
else
    if [[ $VOLUME -eq 0 ]]; then
        ICON=
    elif [[ $VOLUME -lt 50 ]]; then
        ICON=
    else
        ICON=
    fi
    MESSAGE="Громкость: $VOLUME%"
fi

# Отправляем уведомление
notify-send -a "volume_notify" -h  int:value:$VOLUME "Громкость"
