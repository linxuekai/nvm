npm_prefix=/opt/nvm/npm_global

for bin_path in /opt/nvm/node-current/bin $npm_prefix/bin; do
  echo $PATH | grep -qE "${bin_path}[:$]" ||
    export PATH=$bin_path:$PATH
done

grep -qP "^prefix=$npm_prefix$" ~/.npmrc 2>/dev/null ||
  echo "prefix=$npm_prefix" >>~/.npmrc
