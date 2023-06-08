When using AWS vault and multiple accounts + google chrome, this script comes handy, easy to extend to more profiles

Original post: https://cloudar.be/awsblog/using-aws-vault-with-mulitple-browser-windows/


```
$ cat .config/fish/functions/adev.fish
function adev
	aws-vault exec dev --duration=12h
	kitty @ set-window-title "aws dev cli"
end
```

```
$ cat .config/fish/functions/wdev.fish
function wdev
    set -l profile "dev"
    set -l user_data_dir "$HOME/.aws/awschrome/$profile"
    set -l set new_window_arg ''
    set new_window_arg '--new-window'

    # run aws-vault
    # --prompt osascript only works on OSX
    set -l url (aws-vault login $profile --duration=12h --stdout --prompt osascript)

    if test $status -ne 0
        # fish will also capture stderr, so echo $url
        echo $url >&2
        return $status
    end

    mkdir -p $user_data_dir
    set -l disk_cache_dir (mktemp -d /tmp/awschrome_cache.XXXXXXXX)
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
        --no-first-run \
        --user-data-dir=$user_data_dir \
        --disk-cache-dir=$disk_cache_dir \
        $new_window_arg \
        $url \
      >/dev/null 2>&1 &
end
```