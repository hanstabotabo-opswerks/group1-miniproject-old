#!/bin/bash

list="schedule.txt"

if [ ! -f "$list" ]; then
    touch "$list"
fi

shift_time() {
    shift=$1
    case $shift in
        morning)
            echo "6am-3pm"
            ;;
        mid)
            echo "2pm-11pm"
            ;;
        night)
            echo "10pm-7am"
            ;;
    esac
}

display_schedule() {
        team=("A1" "A2" "A3" "B1" "B2" "B3")

        for team in "${team[@]}"; do
            echo "$team"
            if grep -q " $team$" "$list"; then
            	grep " $team$" "$list" | while read -r line; do
                	name=$(echo "$line" | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}')
                	shift=$(echo "$line" | awk '{print tolower($2)}')
                	time=$(shift_time "$shift")
                	echo "   $name, $shift, $time"
        	done
            else
                echo " "
            fi
        done
}

shift_full() {
    team=$1
    shift=$2
    count=$(grep -c "$shift $team" "$list")
    if [ "$count" -ge 2 ]; then
        return 0
    else
        return 1
    fi
}

add_employee() {
    name=$1
    shift=$2
    team=$3

    if shift_full "$team" "$shift"; then
        echo "Error: $shift shift in group $team is already full."
        return 1
    else
        echo "$name $shift $team" >> "$list"
        echo "Shift created!"
        return 0
    fi
}

while true; 

do
    read -p "Enter name: " name

    if [ "$name" == "print" ]; then
        display_schedule
        exit 0
    fi

    read -p "Enter shift (morning/mid/night): " shift
    if ! [[ "$shift" =~ ^(morning|mid|night)$ ]]; then
        echo "Invalid shift. Available shifts: 'morning' 'mid' 'night'"
        continue
    fi

    read -p "Enter team (A1, A2, A3, B1, B2, B3): " team
    if ! [[ "$team" =~ ^(A1|A2|A3|B1|B2|B3)$ ]]; then
        echo "Invalid team. Available team 'A1' 'A2' 'A3' 'B1' 'B2' 'B3'"
        continue
    fi

    add_employee "$name" "$shift" "$team" || continue

done 

