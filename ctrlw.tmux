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

key() {
    local key="$1" commands="$2"
    tmux bind -Tctrlw "$key" "\\
        set-option -g @ctrlw_active 0 ;\\
        ${commands}
    "
}

addCtrlwModeBindings() {
    key '=' "select-layout -E"

    for (( i = 0; i <= 9; i++ )); do
        key $i "select-pane -t $i"
    done

    key h "select-pane -L"
    key j "select-pane -D"
    key k "select-pane -U"
    key l "select-pane -R"
    key p "select-pane -t '!'"

    key '|' "split-window -h -c '#{pane_current_path}'"
    key '-' "split-window -v -c '#{pane_current_path}'"

    ## REPLy stuff
    local replPane=$(getTmuxOption "@ctrlw_repl_pane" '{bottom-right}')
    key r "select-pane -t '$replPane'"
    key , "send-keys -t '$replPane' C-p Enter"

    # To reset @ctrlw_active
    key Any ''
}

addCtrlwSwapMode() {
    # C-w s N - swap current with pane N
    tmux bind -Tctrlw s switch-client -Tctrlw-swap

    for (( i = 0; i <= 9; i++ )); do
        tmux bind -Tctrlw-swap $i "\\
            set-option -g @ctrlw_active 0 ;\\
            swap-pane -t $i
        "
    done
    tmux bind -Tctrlw-swap p '\
        set-option -g @ctrlw_active 0 ;\
        swap-pane -t "!"
    '
    tmux bind -Tctrlw-swap Any '\
        set-option -g @ctrlw_active 0 ;\
    '
}

createCtrlwMode() {
    local ctrlwKey=$(getTmuxOption "@ctrlw_key" "C-w")
    tmux bind -Troot $ctrlwKey '\
        set-option -g @ctrlw_active 1 ;\
        switch-client -Tctrlw
    '
    key . "send-keys $ctrlwKey"
    key $ctrlwKey "send-keys $ctrlwKey"

    local plainKey="${ctrlwKey#*-}"
    key "$plainKey" "send-keys $ctrlwKey"
}

createCtrlwMode
addCtrlwModeBindings
addCtrlwSwapMode
