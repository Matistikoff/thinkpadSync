# Spoločné aliasy; výnimky tohto počítača sa načítajú posledné.
if status is-interactive
    source "$__fish_config_dir/aliases.fish"
    if test -f "$__fish_config_dir/aliases.local.fish"
        source "$__fish_config_dir/aliases.local.fish"
    end
    if test -f "$__fish_config_dir/config.local.fish"
        source "$__fish_config_dir/config.local.fish"
    end
end
