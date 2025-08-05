# Setup

Be sure to clone it or move it to `~/.dev/configs`. As the script symlink from that directory.
You can update the `./setup.sh` if you want a different location.

Run `./setup.sh` to symlink configurations.

Add this to `~/.zshrc` to fix issue with tmux Alt/Meta key in macOs

```
# Force the right key bindings for tmux
if [[ -n "$TMUX" ]]; then
    bindkey "^[b" backward-word
    bindkey "^[f" forward-word
    bindkey "^[[1;3D" backward-word  # Alt+Left
    bindkey "^[[1;3C" forward-word   # Alt+Right
    bindkey "^[^?" backward-kill-word  # Alt+Backspace
    bindkey "^[^H" backward-kill-word  # Alt+Backspace (alternative)
fi
```

Also this if working with virtual env with python

```
# setup .venv
autoload -U add-zsh-hook
auto_venv_activate() {
  if [[ -f .venv/bin/activate ]]; then
    source .venv/bin/activate
  fi
}

add-zsh-hook chpwd auto_venv_activate
auto_venv_activate  # activate on shell start
```

## Tmux

Install tpm to manage tmux plugins

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Attach to a tmux session or start a new one using `tmux a` or `tmux`. Press `<Prefix> + I` to install the plugins of tmux.

### Tmux Session Manager (tsm)
We have utility for tmux-resurrect to allow managing session per project. It is located on `.tmux/utils/tsm`

Add tsm directory to `PATH` in `~/.zshrc`

```
# custom tmux utilities 
export PATH="$HOME/.tmux/utils:$PATH"
```

To use save and restore:

```
tsm save <project>
tsm restore <project>
```

To list all the session:
```
tsm list
```

## VIM

Install vim plug:
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then open any file or directory using `vim`.

Press `:` to trigger commands then `PlugInstall`.

## NVIM
This is automatic setup. Will automatically install the required plugins.

### PyLSP
For pylsp to work need to install additional requirements:

```
source ~/.venv/bin/active
uv pip install python-lsp-black python-lsp-isort
```

Make sure to close current `nvim` and run `source .venv/bin/activate` for nvim to detect pylsp.
