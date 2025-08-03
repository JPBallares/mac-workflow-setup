# Force the right key bindings for tmux
if [[ -n "$TMUX" ]]; then
    bindkey "^[b" backward-word
    bindkey "^[f" forward-word
    bindkey "^[[1;3D" backward-word  # Alt+Left
    bindkey "^[[1;3C" forward-word   # Alt+Right
    bindkey "^[^?" backward-kill-word  # Alt+Backspace
    bindkey "^[^H" backward-kill-word  # Alt+Backspace (alternative)
fi

export EDITOR='nvim'
export PATH="$HOME/.homebrew/bin:$PATH"


# nvm config
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# node
export NODE_OPTIONS="--max-old-space-size=4096"

# uv (python package manager made with rust)
. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# uv python
export PYTHON_PATH="$HOME/.local/share/uv/python/cpython-3.11.11-macos-aarch64-none"
export PATH="$PYTHON_PATH/bin:$PATH"

# psql in cli
export PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH

# custom gitui
export PATH="$HOME/.gitui:$PATH"

# custom tmux utilities 
export PATH="$HOME/.tmux/utils:$PATH"

# docker
export PATH="$HOME/.docker/bin:$PATH"

# tmuxinator
fpath+=/Users/admin/.homebrew/share/zsh/site-functions
autoload -Uz compinit && compinit

# setup .venv
autoload -U add-zsh-hook
auto_venv_activate() {
  if [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate
  fi
}

add-zsh-hook chpwd auto_venv_activate
auto_venv_activate  # activate on shell start

# setup .nvmrc
# load-nvmrc() {
#   if [[ -f .nvmrc ]]; then
#     nvm use > /dev/null
#   fi
# }
# add-zsh-hook chpwd load-nvmrc
# load-nvmrc  # run on shell start

