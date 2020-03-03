npm_prefix=/opt/nvm/npm_global

PATH=$npm_prefix/bin:/usr/local/nodejs/bin:$PATH

[ -r ~/.npmrc ] && grep -qP "^prefix=$npm_prefix$" ~/.npmrc || {
  echo "prefix=$npm_prefix" >> ~/.npmrc
}