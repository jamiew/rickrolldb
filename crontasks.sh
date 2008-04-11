#!/usr/local/bin/bash
cd /usr/home/jamie/apps/rickrolldb
/usr/local/bin/rake -t cache_remote_screenshots
/usr/local/bin/rake -t entry_cleanup
