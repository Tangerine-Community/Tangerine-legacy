#!/bin/bash
# Edit this file to match your folders

BACKUP="tangerine-apks"
if [ ! -d "$BACKUP" ]; then
mkdir $HOME/$BACKUP
fi

read -p "Do you want to delete your current database and start with a clean, new empty one?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
# Clean out the tangerine DB of any existing assessments or results
curl -H "Content-Type: application/json" -X DELETE http://tangerine:tangytangerine@localhost:5984/tangerine; curl -H "Content-Type: application/json" -X PUT http://tangerine:tangytangerine@localhost:5984/tangerine; cd ../app; couchapp push; cd -
fi

echo
echo "********"
echo "Cleaning"
echo "********"
ant clean
# ant debug clean
echo
echo "********"
echo "Compacting database"
echo "********"
curl -X POST -H "Content-Type: application/json" http://tangerine:tangytangerine@localhost:5984/tangerine/_compact
echo
echo "********"
echo "Building"
echo "********"
ant debug
NOW=$(date +"%Y%m%d-%H")
cp bin/Tangerine-debug.apk bin/Tangerine-$NOW.apk
echo 
echo "************"
echo "Uninstalling"
echo "************"
adb uninstall com.couchbase.callback
echo
echo "**********"
echo "Installing"
echo "**********"
adb install bin/Tangerine-debug.apk
echo
echo "**********"
echo "Backing up to $HOME/$BACKUP"
echo "**********"


FILE="Tangerine-debug.$NOW.tar.gz"
tar czfv $FILE bin/Tangerine-debug.apk
cp -f $FILE $HOME/$BACKUP 
rm $FILE
#adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
