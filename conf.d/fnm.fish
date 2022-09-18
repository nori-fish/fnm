function _fnm_install --on-event fnm_install --on-event fnm_update
    set --query fnm_package_content_type || set --local fnm_package_content_type application/zip
    set --query fnm_package_name_contains || set --local fnm_package_name_contains linux
    set --local current_version

    if command --query fnm
        set current_version (command fnm --version | awk '{print $2}')
    end

    set --local latest_release_json (curl -fs https://api.github.com/repos/schniz/fnm/releases/latest)
    set --local latest_version (echo $latest_release_json | jq -r ".tag_name" | string replace --regex '^v' '' | awk '{print $1}')

    if [ "$current_version" != "$latest_version" ]
        if [ "$current_version" ]
            echo "[fnm] Updating from v$current_version to v$latest_version..."
        else
            echo "[fnm] Installing v$latest_version"
        end

        set --query FNM_DIR
        or set --universal --export FNM_DIR $HOME/.fnm

        curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell

        fish_add_path --prepend $FNM_DIR

        command fnm env | source
    end
end

function _fnm_uninstall --on-event fnm_uninstall
    if set --local index (contains --index $FNM_DIR $fish_user_paths)
        set --universal --erase fish_user_paths[$index]
    end

    if set --query FNM_DIR
        rm -rf $FNM_DIR
        set -Ue FNM_DIR
    end
end


if command --query fnm
    command fnm env | source
end
