# yes I don't use oh my zsh
# I'm stuck, I think
# "well if it works right now, it works"
# but like most things I build,
# my configs are a house of cards

# Load per-machine / private env vars
if [ -f "$HOME/.config/zsh/env.local.zsh" ]; then
  source "$HOME/.config/zsh/env.local.zsh"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# direnv
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# make completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# zsh completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

autoload -Uz compinit
compinit

# carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
source <(carapace _carapace)

# rose-pine fzf coloring
# export FZF_DEFAULT_OPTS="
#   --color=fg:#e0def4,hl:#ebbcba
#   --color=fg+:#9ccfd8,hl+:#ebbcba
#   --color=border:#403d52,header:#31748f
#   --color=spinner:#f6c177,info:#9ccfd8,separator:#403d52
#   --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#9ccfd8"

# anysphere fzf coloring
export FZF_DEFAULT_OPTS="
  --color=fg:#d6d6dd,hl:#AAA0FA
  --color=fg+:#e3e1e3,hl+:#AAA0FA
  --color=border:#383838,header:#4c9df3
  --color=spinner:#e5b95c,info:#75d3ba,separator:#383838
  --color=pointer:#e567dc,marker:#f14c4c,prompt:#228df2
"

# Created by `pipx` on 2025-06-08 14:04:57
export PATH="$PATH:$HOME/.local/bin"

# eza
alias ls="eza --icons=always"

# zoxide
eval "$(zoxide init zsh)"
alias cd="z"

# oh my posh
# eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/rose-pine-mock.omp.json)"

# claude
alias claude="${CLAUDE_BIN:-$HOME/.claude/local/claude}"

# vault (VAULT_ADDR in env file)
alias envdev='envconsul -once -pristine -no-prefix -secret="kv/data/dev" --'

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# go
export PATH="$HOME/go/bin:$PATH"

# gitingest
alias "gitingest-clean"='gitingest -e "*.ttf" -e "*.png" -e "pnpm-lock.yaml" -o "$HOME/Downloads/digest.txt"'

alias cloc-phyt='cloc "$HOME/Developer/phyt.fun" --vcs=git --exclude-dir=dist,coverage,build --exclude-ext=lock,json,yaml'

alias vim="nvim"
# alias vi="nvim"
# alias nvim="nvim ."

# Tmux auto setup
# alias ta="~/.tmux/auto-setup.sh"

# nix clean backups
function nix-clean-backups() {
  local files=(
    /etc/bashrc.backup-before-nix
    /etc/zshrc.backup-before-nix
    /etc/bash.bashrc.backup-before-nix
  )
  for f in $files; do
    if [[ -f $f ]]; then
      echo "Removing stale backup: $f"
      sudo rm -f "$f"
    fi
  done
  echo "Done. You can safely re-run the Nix installer now."
}

# zsh completion suggestions
# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh color
# source ~/.config/zsh/rose-pine-zsh/rose-pine-zsh.zsh
# colorize_zsh "rose-pine"

# uv
eval "$(uv generate-shell-completion zsh)"

# dotfiles
dotfiles() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}
compdef _git dotfiles=git
# alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
# compdef dotfiles=git

compdef _git dotfiles=git

lazydot() {
  lazygit --git-dir="$HOME/.dotfiles" --work-tree="$HOME"
}

# sesh (outside of tmux) picker
function sesh-sessions() {
  {
    if [[ -n "$TMUX" || -n "$NVIM_LISTEN_ADDRESS" ]]; then
      return
    fi

    exec </dev/tty
    exec <&1

    local list_cmd="LC_ALL=en_US.UTF-8 sesh list --icons -d -c -z"

    local session
    session=$(
      eval "$list_cmd" | fzf-tmux -p 80%,70% \
        --layout=reverse \
        --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
        --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
        --bind 'tab:down,btab:up' \
        --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
        --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
        --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
        --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
        --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
        --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
        --preview-window 'right:55%' \
        --preview 'sesh preview {}'
    )

    zle reset-prompt >/dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect "$session"
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '__SUPER_S__' sesh-sessions
bindkey -M vicmd '__SUPER_S__' sesh-sessions
bindkey -M viins '__SUPER_S__' sesh-sessions

# aliases
alias nv='nvim'                                                                                                          # Open neovim (alternative)
alias z-='z -'                                                                                                           # Navigate to previous directory using zoxide
alias cd..='z ..'                                                                                                        # Go up one directory using zoxide
alias z..='z ..'                                                                                                         # Go up one directory using zoxide (alternative)
alias ..='z ..'                                                                                                          # Go up one directory using zoxide
alias ...='z ../..'                                                                                                      # Go up two directories using zoxide
alias ....='z ../../..'                                                                                                  # Go up three directories using zoxide
alias zfreq='zoxide query -l'                                                                                            # List most frequently used directories
alias yy='yazi'                                                                                                          # Open yazi
alias fct='find . -maxdepth 1 -type d ! -name ".*" | wc -l'                                                              # Count number of directories in the current directory (excluding hidden ones)
alias func='functions'                                                                                                   # List all functions
alias cat='bat'                                                                                                          # Use bat instead of cat
alias oldcat='cat'                                                                                                       # Use original cat
alias l='eza --group-directories-first --icons=always'                                                                   # List with icons, directories first
alias ls='eza --group-directories-first --icons=always'                                                                  # List with icons, directories first
alias ll='eza -l --group-directories-first --icons=always'                                                               # Long format with icons
alias la='eza -la --group-directories-first --icons=always'                                                              # List all (including hidden) with icons
alias lt='eza --tree --icons=always'                                                                                     # Tree view with icons
alias l.='eza -a  --icons=always | grep -E "^\."'                                                                        # Show only hidden files
alias lsa='eza -la --group-directories-first --icons=always'                                                             # List all with icons (including hidden)
alias lsr='eza -R --icons=always'                                                                                        # List recursively
alias lsf='eza -1  --icons=always | wc -l'                                                                               # Count number of files
alias lss='eza -la --group-directories-first --sort=size --icons=always'                                                 # Sort by size
alias cls='clear'                                                                                                        # Clear the terminal screen
alias oldtop="/usr/bin/top"                                                                                              # Run the original top command
alias nf="neofetch"                                                                                                      # Display system information using neofetch
alias of='onefetch --no-color-palette --include-hidden -E --no-title --ascii-input "$(cat ~/dotfiles/logos/logo.txt)"'   # Display git repository information using onefetch with logo
alias ep="echo $PATH"                                                                                                    # Print the PATH environment variable
alias resh="source ~/.config/fish/config.fish"                                                                           # Reload the fish configuration

alias ftl='find . -type f -name "*.*" -exec basename {} \; | sed "s/.*\.//" | sort -u'                                   # List unique file extensions in current directory

alias ga='git add'                      # Stage changes
alias gaa='git add .'                   # Stage all changes in current directory
alias gaaa='git add -A'                 # Stage all changes
alias gc='git commit'                   # Commit changes
alias gcm='git commit -m'               # Commit changes with a message
alias gbr='git branch -M'               # Rename current branch
alias gcr='git clone'                   # Clone a repository
alias gd='git diff'                     # Show changes between commits, commit and working tree, etc.
alias gds='git diff --stat'             # Show diff stats (files changed, insertions, deletions)
alias gi='git init'                     # Initialize a new Git repository
alias gl='git log'                      # Show commit logs
alias gp='git pull'                     # Fetch from and integrate with another repository or a local branch
alias gpsh='git push'                   # Update remote refs along with associated objects
alias gss='git status'                  # Show the working tree status
alias gwho='git shortlog -s -n | head'  # Show top contributors
alias gcnt='git ls-files | wc -l'       # Count number of files in the repository
alias lg='lazygit'                      # Open Lazygit interface
alias grl='gh repo ls 956MB'            # List my repos on GitHub
alias grlf='gh repo ls 956MB --fork'    # List my forked repos on GitHub

# GitHub Copilot CLI function aliases
exp() {
    gh copilot explain "$*"
}
sug() {
    gh copilot suggest "$*"
}

# LaTeX
export PATH="/Library/TeX/texbin:$PATH"
alias skim='/Applications/Skim.app/Contents/MacOS/Skim'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# global editor (yazi)
# NOTE: this changes behavior of terminal editing
# so just forcing it in ~/.config/yazi/yazi.toml
# export EDITOR="nvim"
# export VISUAL="nvim"

# starship
eval "$(starship init zsh)"

# zsh syntax highlighting
# source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
# source ~/.zsh/sakura-zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source "$HOME/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

