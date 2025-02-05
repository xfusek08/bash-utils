require_once "$LIB_PATH/log.zsh"

log "executing on-compilation-finish.zsh"

autoload -Uz compinit

compinit
