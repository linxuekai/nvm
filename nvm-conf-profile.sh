npm_prefix=/opt/nvm/npm_global

echo $PATH | grep -qE "${npm_prefix}/bin[:$]" ||
  export PATH=$npm_prefix/bin:$PATH

grep -qP "^prefix=$npm_prefix$" ~/.npmrc 2>/dev/null ||
  echo "prefix=$npm_prefix" >>~/.npmrc
