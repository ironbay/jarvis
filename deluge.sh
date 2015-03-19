#!/bin/bash
id=$1
name=$2
path=$3
echo $2 >> /tmp/torrents.log
curl --data '{ "Name" : "'$name'", "Path" : "'$path/$name'" }' http://localhost:11000/event/TorrentFinished
