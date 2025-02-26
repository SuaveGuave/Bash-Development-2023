#!/bin/bash

#this program allows the user to play a game of blackjack. It will draw two cards for the user and dealer, with one of the dealers cards hidden,
#the user will then have the choice of hitting or standing, upon standing, the dealer will have their turn, following conventional dealer rules,
#not standing until their hand value is >17. The game implements a charlie system for if you have 5 cards in your hand for an instant win.

initialise_deck() {
    suits=("Hearts" "Diamonds" "Clubs" "Spades")
    values=("2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K" "A")
    deck=()
    for suit in "${suits[@]}"; do
        for value in "${values[@]}"; do
            deck+=("$value of $suit")
        done
    done
}
#function to initialise the deck

deal_card() {
    local index=$((RANDOM % ${#deck[@]}))
    local card="${deck[index]}"
    unset 'deck[index]'
    echo "$card"
}
#function to deal a card

calculate_hand_value() {
    local hand=("$@")
    local value=0
    local ace_count=0
    for card in "${hand[@]}"; do
        local card_value="${card%% *}"
        case "$card_value" in
            "J"|"Q"|"K") value=$((value + 10));;
            "A") value=$((value + 11)); ace_count=$((ace_count + 1));;
            *) value=$((value + $card_value));;
        esac
    done
    while [ $value -gt 21 ] && [ $ace_count -gt 0 ]; do
        value=$((value - 10))
        ace_count=$((ace_count - 1))
    done
    echo "$value"
}
#function to calculate the value of a hand

display_hand() {
    local player=$1
    shift
    local hand=("$@")
    echo "$player hand:"
    for card in "${hand[@]}"; do
        echo "$card"
    done
    echo "Total value: $(calculate_hand_value "${hand[@]}")"
}
#function to display a hand

determine_winner() {
    local player_total="$1"
    local dealer_total="$2"
    if [ "$player_total" -gt 21 ]; then
        echo "Busted! You lose."
    elif [ "$dealer_total" -gt 21 ] || [ "$player_total" -gt "$dealer_total" ]; then
        echo "Congratulations! You win."
    elif [ "$player_total" -eq "$dealer_total" ]; then
        echo "It's a tie. You get your bet back."
    else
        echo "Sorry, you lose."
    fi
}
#function to determine the winner

#program starts here
echo "Welcome to Blackjack!"

initialise_deck

player_hand=()
dealer_hand=()

player_hand+=("$(deal_card)")
dealer_hand+=("$(deal_card)")

player_hand+=("$(deal_card)")
dealer_hand+=("$(deal_card)")

display_hand "Your" "${player_hand[@]}"
echo ""
echo "Dealer's hand:"
echo "${dealer_hand[0]}"
echo "Second card: ???"
echo "Total value: ???"
#display initial hands

#player's turn
while true; do
    echo ""
    read -p "Do you want to hit or stand? (h/s): " choice
    case "$choice" in
        "h") card="$(deal_card)"
             player_hand+=("$card")
             echo "You drew: $card"
             display_hand "Your" "${player_hand[@]}"
             echo ""
             player_total="$(calculate_hand_value "${player_hand[@]}")"
             if [ "$player_total" -gt 21 ]; then
                 echo "Busted! You lose."
                 exit
             elif [ "${#player_hand[@]}" -eq 5 ]; then
                 echo "Charlie! You win."
                 exit
             fi;;
        "s") break;;
        *) echo "Invalid choice. Please enter 'h' for hit or 's' for stand.";;
    esac
done

#dealer's turn
while [ "$(calculate_hand_value "${dealer_hand[@]}")" -lt 17 ]; do
    dealer_hand+=("$(deal_card)")
done

echo ""
display_hand "Your" "${player_hand[@]}"
echo ""
display_hand "Dealer's" "${dealer_hand[@]}"
#display final hands

player_total="$(calculate_hand_value "${player_hand[@]}")"
dealer_total="$(calculate_hand_value "${dealer_hand[@]}")"
determine_winner "$player_total" "$dealer_total"
#determine the winner
