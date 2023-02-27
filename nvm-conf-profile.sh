npm_prefix=/opt/nvm/npm_global

echo $PATH | grep -qE "${npm_prefix}/bin[:$]" ||
  export PATH=$npm_prefix/bin:$PATH
