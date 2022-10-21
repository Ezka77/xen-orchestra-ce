import os, json
from urllib.request import urlopen

urls = {
    "xoaserver": "https://raw.githubusercontent.com/vatesfr/xen-orchestra/master/packages/xo-server/package.json",
    "xoaweb": "https://raw.githubusercontent.com/vatesfr/xen-orchestra/master/packages/xo-web/package.json"
     }

def env_push(k, url):
    with urlopen(url) as f:
        resp = json.load(f)
    # echo "version=$VERSION" >> $GITHUB_OUTPUT
    try:
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"{k}={resp['version']}\n")
    except KeyError as error:
        print(err)
        raise

try:
    for k, v in urls.items():
        env_push(k, v)
except Exception as err:
    print(err)
    raise
