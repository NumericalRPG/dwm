#!/bin/bash

# Шаг изменения яркости (в %)
STEP=5

# Минимальная и максимальная яркость (в %)
MIN=5
MAX=100

# Получаем текущую яркость
CURRENT=$(brightnessctl get)
MAX_BRIGHTNESS=$(brightnessctl max)
PERCENT=$((CURRENT * 100 / MAX_BRIGHTNESS))

case $1 in
    up)
        # Увеличиваем яркость
        brightnessctl set ${STEP}%+ > /dev/null
        PERCENT=$(( (CURRENT + (MAX_BRIGHTNESS * STEP / 100)) * 100 / MAX_BRIGHTNESS ))
        ;;
    down)
        # Уменьшаем яркость
        brightnessctl set ${STEP}%- > /dev/null
        PERCENT=$(( (CURRENT - (MAX_BRIGHTNESS * STEP / 100)) * 100 / MAX_BRIGHTNESS ))
        ;;
esac

# Ограничиваем значения
if [[ $PERCENT -gt $MAX ]]; then
    PERCENT=$MAX
elif [[ $PERCENT -lt $MIN ]]; then
    PERCENT=$MIN
fi

# Отправляем уведомление
notify-send -a "brightness_notify" -h "int:value:$PERCENT" "Яркость" "$PERCENT%"
