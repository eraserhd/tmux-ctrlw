#! /usr/bin/env bash

getTmuxOption() {
    local option="$1"
    local defaultValue="$2"
    local optionValue=$(tmux show-option -gqv "$option")
    if [[ -n $optionValue ]]; then
        printf '%s' "$optionValue"
    else
        printf '%s' "$defaultValue"
    fi
}

addCtrlwModeBindings() {
    tmux bind -Tctrlw = select-layout -E

    for (( i = 0; i <= 9; i++ )); do
        tmux bind -Tctrlw $i select-pane -t $i
    done

    tmux bind -Tctrlw h select-pane -L
    tmux bind -Tctrlw j select-pane -D
    tmux bind -Tctrlw k select-pane -U
    tmux bind -Tctrlw l select-pane -R
    tmux bind -Tctrlw p select-pane -t "!"

    ## REPLy stuff
    local replPane=$(getTmuxOption "@ctrlw_repl_pane" '{bottom-right}')
    tmux bind -Tctrlw r select-pane -t "$replPane"
    tmux bind -Tctrlw , send-keys -t "$replPane" C-p Enter
}

addCtrlwSwapMode() {
    # C-w s N - swap current with pane N
    tmux bind -Tctrlw s switch-client -Tctrlw-swap

    for (( i = 0; i <= 9; i++ )); do
        tmux bind -Tctrlw-swap $i swap-pane -t $i
    done
    tmux bind -Tctrlw-swap p swap-pane -t "!"
}

createCtrlwMode() {
    local ctrlwKey=$(getTmuxOption "@ctrlw_key" "C-w")
    tmux bind -Troot $ctrlwKey switch-client -Tctrlw
    tmux bind -Tctrlw . send-keys $ctrlwKey
    tmux bind -Tctrlw $ctrlwKey send-keys $ctrlwKey

    local plainKey="${ctrlwKey#*-}"
    tmux bind -Tctrlw "$plainKey" send-keys $ctrlwKey
}

createCtrlwMode
addCtrlwModeBindings
addCtrlwSwapMode
