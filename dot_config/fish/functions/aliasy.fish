function aliasy --description 'Upraviť vlastné aliasy v Neovime'
    set -l alias_file "$__fish_config_dir/aliases.fish"
    command nvim "$alias_file"
    or return $status
    if command fish --no-config --no-execute "$alias_file"
        source "$alias_file"
    else
        printf '%s\n' 'Aliasy obsahujú chybu syntaxe. Oprav ich príkazom aliasy.' >&2
        return 1
    end
end
