npm_prefix=/opt/nvm/npm_global

PATH=$npm_prefix/bin:/opt/nvm/node-current/bin:$PATH

[ -r ~/.npmrc ] && grep -qP "^prefix=$npm_prefix$" ~/.npmrc || {
  echo "prefix=$npm_prefix" >> ~/.npmrc
}