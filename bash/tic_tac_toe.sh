#!/bin/bash
save_file="save.txt"
board=( 1 2 3 4 5 6 7 8 9 1 0) #board[9] is a round, board[10] is isAi

saving_game(){
    for i in {0..10}; do
        echo "${board[i]}" 
    done > "$save_file"
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
        echo "win"
    fi

    if (( board[9] > 9 )); then
       echo "tie"
    fi
}

computer_move(){
    local chosen=""
    local winning_moves=( 
        0 1 2
        0 3 6
        0 4 8
        1 4 7
        2 5 8
        2 4 6
        3 4 5
        6 7 8
    )

    local available_moves=()
    for ((i=0; i<9; i+=1)); do
        if [[ "${board[i]}" != "X" && "${board[i]}" != "O" ]]; then
            available_moves+=("$i")
        fi
    done
    chosen="${available_moves[$((RANDOM % ${#available_moves[@]}))]}"

    for ((i = 0; i < ${#winning_moves[@]}; i += 3)); do
        local first=${winning_moves[i]}
        local second=${winning_moves[i+1]}
        local third=${winning_moves[i+2]}

        if [[ "${board[first]}" == "X" && "${board[third]}" == "X" && "${board[first]}" != "X" && "${board[first]}" != "O" ]]; then
            chosen=("$first")
            break
        elif [[ "${board[first]}" == "X" && "${board[third]}" == "X" && "${board[second]}" != "X" && "${board[second]}" != "O" ]]; then
            chosen=("$second")
            break
        elif [[ "${board[first]}" == "X" && "${board[second]}" == "X" && "${board[third]}" != "X" && "${board[third]}" != "O" ]]; then
            chosen=("$third")
            break
        fi
    done

    for ((i = 0; i < ${#winning_moves[@]}; i += 3)); do
        local first=${winning_moves[i]}
        local second=${winning_moves[i+1]}
        local third=${winning_moves[i+2]}

        if [[ "${board[first]}" == "O" && "${board[third]}" == "O" && "${board[first]}" != "O" && "${board[first]}" != "X" ]]; then
            chosen=("$first")
            break
        elif [[ "${board[first]}" == "O" && "${board[third]}" == "O" && "${board[second]}" != "O" && "${board[second]}" != "X" ]]; then
            chosen=("$second")
            break
        elif [[ "${board[first]}" == "O" && "${board[second]}" == "O" && "${board[third]}" != "O" && "${board[third]}" != "X" ]]; then
            chosen=("$third")
            break
        fi
    done
    
    echo "$chosen"
}

play_round(){
    while true; do
        echo "Round ${board[9]}"
        echo ""
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

        if [[ "${board[10]}" == 1 && "$active_player" == 2 ]]; then
            ai_move=$(computer_move)
            board[ai_move]="O"
        else
            while true; do
                read chosen_field
                index=$((chosen_field - 1))
                if [[ "${board[index]}" != "X" && "${board[index]}" != "O" && "$chosen_field" =~ ^[1-9]$ ]]; then
                    board[index]=$sign
                    break
                else
                    echo "Invalid field. Choose another field."
                fi
            done
        fi

        ((board[9]++))

        result=$(check_if_win)
        if [[ "$result" == "win" ]]; then
            echo ""
            echo "Winner: Player $active_player!"
            printing_board
            rm -f "$save_file"
            echo ""
            break
        elif [[ "$result" == "tie" ]]; then
            echo "" 
            echo "It's a tie!"
            printing_board
            rm -f "$save_file"
            echo ""
            break
        fi 
        saving_game
    done

    starting_game
}

starting_game(){
    if [[ -f "$save_file" ]]; then
        echo "It seems you already started playing, you want to continue?"
        echo "1) yes"
        echo "2) no"
        read -r option
    
        case $option in 
            1)
            mapfile -t save < "$save_file"
            for i in {0..10}; do
                board[i]="${save[i]}"
            done
            play_round
            ;;
        
            2)
            rm -f "$save_file"
            options
            ;;
        
            *)
            echo  "Wrong answer"
            echo ""
            starting_game
            ;;
        esac
    else
		options
    fi
}

options(){
    echo "Welcome to tic-tac-toe. The game is saving your progress after every round."
    echo "Select mode:"
    echo "1) 2 player game"
    echo "2) player vs computer"
    echo "3) exit"
    echo ""
    read -r option
    board=( 1 2 3 4 5 6 7 8 9 1 0)

    case $option in 
        1)
        echo "Welcome players"
        board[10]=0
        play_round
        ;;
    
        2)
        echo  "Welcome player"
        board[10]=1
        play_round
        ;;

        3)
        exit 0
        ;;
    
        *)
        echo  "Wrong answer"
        echo ""
        options
        ;;
    esac
}

starting_game