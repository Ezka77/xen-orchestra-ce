
# link all plugins
PACKAGES_DIR=/home/node/xen-orchestra/packages

for elem in $(find $PACKAGES_DIR -maxdepth 1 -type d -name "xo-server-*"); do
    cd $elem
    yarn link
    cd /home/node/xen-orchestra/packages/xo-server/node_modules
    yarn link $(basename $elem)
done;

