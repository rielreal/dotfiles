HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HISTORY_IGNORE='(c|clear|ls|l|ll|pwd|exit|..)'
setopt extended_history share_history hist_ignore_all_dups hist_ignore_space hist_expire_dups_first hist_verify
setopt auto_cd auto_pushd pushd_ignore_dups pushd_minus interactive_comments

eval "$(dircolors -b)"
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
_comp_options+=(globdots)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{8}%d%f'

bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H' backward-kill-word

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
eval "$(starship init zsh)"
starship_full_prompt=$PROMPT
collapse_prompt() {
    PROMPT='%F{5}❯%f '
    zle .reset-prompt
}
restore_prompt() {
    PROMPT=$starship_full_prompt
}
zle -N zle-line-finish collapse_prompt
precmd_functions+=(restore_prompt)

eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"

source_first() {
    local candidate
    for candidate in "$@"; do
        [[ -r $candidate ]] && { source "$candidate"; return; }
    done
}
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source_first /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_first /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_STYLES[command]='fg=5'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=5'
ZSH_HIGHLIGHT_STYLES[alias]='fg=5'
ZSH_HIGHLIGHT_STYLES[function]='fg=5'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=5,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=1'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=3'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=3'
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'

nvm() {
    unfunction nvm
    source /usr/share/nvm/nvm.sh
    nvm "$@"
}

fastfetch_marker="$XDG_RUNTIME_DIR/fastfetch-shown"
if [[ -t 1 && -n "$KITTY_WINDOW_ID" && $SHLVL -eq 1 && $COLUMNS -ge 90 && ! -e $fastfetch_marker ]]; then
    fastfetch
    : > "$fastfetch_marker"
fi
unset fastfetch_marker

alias clear='printf "\033_Ga=d,d=A\033\\\\\033[2J\033[3J\033[H"'
alias c='clear'
alias ..='cd ..'
alias mkdir='mkdir -p'
alias ff='fastfetch'
alias ls='eza --icons=auto --group-directories-first'
alias l='eza -lh --icons=auto --group-directories-first --git'
alias ll='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
alias cat='bat --style=plain --paging=never'
alias grep='grep --color=auto'

alias reload='source $ZDOTDIR/.zshrc'
alias bios='systemctl reboot --firmware-setup'

[[ -r "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
[[ -f "$ZDOTDIR/.secrets.zsh" ]] && source "$ZDOTDIR/.secrets.zsh"
