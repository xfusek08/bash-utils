
require_once "$ZSH_SCRIPTING_DIRECTORY/features/zinit.zsh"

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory # append history to the history file
setopt sharehistory # share history between sessions
setopt hist_ignore_space # ignore commands starting with a space
setopt hist_ignore_all_dups # ignore duplicate commands
setopt hist_save_no_dups # do not save duplicate commands
setopt hist_ignore_dups # ignore duplicate commands
setopt hist_find_no_dups # do not display duplicate commands
