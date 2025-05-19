#!/bin/bash




chosen_field=" "
board=( 1 2 3 4 5 6 7 8 9 )
active_player=1
round=1
sign="X"


printing_board(){
    echo "${board[0]} | ${board[1]} | ${board[2]}"
    echo "---------"
    echo "${board[3]} | ${board[4]} | ${board[5]}"
    echo "---------"
    echo "${board[6]} | ${board[7]} | ${board[8]}"
}

check_if_win(){
    
    if [ "${board[0]}" == "${board[1]}" ] && [ "${board[1]}" == "${board[2]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    elif [ "${board[3]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[5]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    elif [ "${board[6]}" == "${board[7]}" ] && [ "${board[7]}" == "${board[8]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    fi
    if [ "${board[0]}" == "${board[3]}" ] && [ "${board[3]}" == "${board[6]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    elif [ "${board[1]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[7]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    elif [ "${board[2]}" == "${board[5]}" ] && [ "${board[5]}" == "${board[8]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    fi
    if [ "${board[0]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[8]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    elif [ "${board[2]}" == "${board[4]}" ] && [ "${board[4]}" == "${board[6]}" ]; then
        printing_board
        echo "Winner player $active_player"
	sleep 5
        exit 0
    fi
    if (( round > 9 )); then
        printing_board
        echo "It's a tie!"
	sleep 5
        exit 0
    fi
}

switching_fields(){
    read chosen_field
    if [[ ${board[$((chosen_field - 1))]} != "X" && ${board[$((chosen_field - 1))]} != "O" ]]; then
        board[$((chosen_field - 1))]=$sign
        ((round++))
        check_if_win
    else
        echo "Invalid field"
    fi
    play_round
}

play_round(){
    echo "Round $round"
    printing_board
    if (( round % 2 == 1 )); then
        sign="X"
        active_player=1
        echo "Player 1 choose the field"
    else
        sign="O"
        echo "Player 2 choose the field"
        active_player=2
        fi
        switching_fields
    }

starting_game(){
    options
}


options(){
    echo "Select mode:"
    echo "1) 2 player game"
    echo "2) 1 player game"
    read -r option

    case $option in 
        1)
        echo "Welcome players"
        game_mode=1
        play_round
        ;;
    
        2)
        echo  "Welcome player"
        game_mode=2
        echo "Not yet implemented"
        options
        ;;
    
        *)
        echo  "Wrong answer"
        options
        ;;
    esac
}


echo "Welcome to tic-tac-toe."
starting_game
