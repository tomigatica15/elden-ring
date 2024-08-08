#!/bin/bash
json=$(cat characters.json)

set_character() {
    local character_type=$1

    name=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].name')
    damage=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].damage')
    health=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].health')
}

set_vil() {
    local character_type=$1

    vil_name=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].name')
    vil_damage=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].damage')
    vil_health=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].health')
    vil_lvl=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].level')
    vil_prob=$(echo "$json" | jq -r --arg type "$character_type" '.[$type].random_prob')
}

character_info() {
    echo "Nombre: $name"
    echo "Daño: $damage"
    echo "Salud: $health"
}

echo "Elige con qué personaje quieres jugar."
sleep 1
echo -n "Mago (1) Asesino (2) Tanque (3): "
read user

if [[ $user == "1" ]]; then
    char="Mago"
elif [[ $user == "2" ]]; then
    char="Asesino"
else
    char="Tanque"
fi

clear
set_character "$char"
character_info

set_vil "1"
echo "Te has encontrado con $vil_name"

combat() {
    sleep 1
    echo "Tienes que terminar con $vil_name"
    echo -n "Elige un número (0-$((vil_prob-1))): "
    read move

    prob=$((RANDOM % vil_prob))

    if [[ $move -ne $prob ]]; then
        #Jugador erro
        char_life=$(echo "$health - $vil_damage" | bc)
        health=$char_life

        if (( $(echo "$health <= 0" | bc -l) )); then
            echo "Moriste."
            echo "Fin del juego"
            exit 1
        else
            echo "El $vil_name te ha atacado, tienes $health de vida"
            combat
        fi
    else
        #Jugador acerto
        vil_life=$(echo "$vil_health - $damage" | bc)
        vil_health=$vil_life

        if (( $(echo "$vil_health <= 0" | bc -l) )); then
            echo "Acabaste con $vil_name."
            echo "Sigues avanzando"
            vil_lvl=$((vil_lvl + 1))
            sleep 2
	    clear
            detect_lvl
	else
            echo "Le pegaste, tiene $vil_health de vida"
            combat
        fi
    fi
}

detect_lvl() {
    case $vil_lvl in
        1) set_vil "1" ;;
        2) set_vil "2" ;;
        3) set_vil "3" ;;
        *) echo "Ganaste, felicitaciones."
           exit 1 ;;
    esac
    combat
}

detect_lvl
