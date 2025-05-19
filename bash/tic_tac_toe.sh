#!/bin/bash
save_file="save.txt"
chosen_field=" "
board=( 1 2 3 4 5 6 7 8 9 1) #board[9] is a round
active_player=1
sign="X"

saving_game(){
    echo "${board[*]}" > "$save_file"
}

printing_board(){
    echo "${board[0]} | ${board[1]} | ${board[2]}"
    echo "---------"
    echo "${board[3]} | ${board[4]} | ${board[5]}"
    echo "---------"
    echo "${board[6]} | ${board[7]} | ${board[8]}"
}

check_if_win(){
    if [[ "${board[0]}" == "${board[1]}" && "${board[1]}" == "${board[2]}" ]] ||
       [[ "${board[3]}" == "${board[4]}" && "${board[4]}" == "${board[5]}" ]] ||
       [[ "${board[6]}" == "${board[7]}" && "${board[7]}" == "${board[8]}" ]] ||
       [[ "${board[0]}" == "${board[3]}" && "${board[3]}" == "${board[6]}" ]] ||
       [[ "${board[1]}" == "${board[4]}" && "${board[4]}" == "${board[7]}" ]] ||
       [[ "${board[2]}" == "${board[5]}" && "${board[5]}" == "${board[8]}" ]] ||
       [[ "${board[0]}" == "${board[4]}" && "${board[4]}" == "${board[8]}" ]] ||
       [[ "${board[2]}" == "${board[4]}" && "${board[4]}" == "${board[6]}" ]]; then
        printing_board
        echo "Winner: Player $active_player!"
        rm -f "$save_file"
		sleep 5
		exit 0
    fi
    if (( board[9] > 9 )); then
        echo "It's a tie!"
		printing_board
        rm -f "$save_file"
		sleep 5
        exit 0
    fi
}

switching_fields(){
    read chosen_field
    if [[ ${board[$((chosen_field - 1))]} != "X" && ${board[$((chosen_field - 1))]} != "O" && "$chosen_field" != "10" ]]; then
        board[$((chosen_field - 1))]=$sign
        ((board[9]++))
        check_if_win
        saving_game
    else
        echo "Invalid field"
    fi
    play_round
}

play_round(){
    echo "Round ${board[9]}"
    printing_board

    if (( board[9] % 2 == 1 )); then
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
    if [[ -f "$save_file" ]]; then
        echo "It seems you already started playing, you want to continue?"
        echo "1) yes"
        echo "2) no"
        read -r option
    
        case $option in 
            1)
			
            IFS=' '
            read -r -a board -d EOF< "$save_file"
			board[9]=$(echo "${board[9]}" | tr -d '\n')
            play_round
            ;;
        
            2)
            rm -f "$save_file"
            options
            ;;
        
            *)
            echo  "Wrong answer"
            starting_game
            ;;
        esac
    else
		options
    fi
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


echo "Welcome to tic-tac-toe. The game is saving your progress after every round."
starting_game