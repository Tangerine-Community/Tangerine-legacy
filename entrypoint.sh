echo ""
echo ""
echo ""
echo "Setting up database user"
echo "$T_ADMIN = $T_PASS" >> /etc/couchdb/local.ini
sudo chown -R couchdb /var/run/couchdb
couchdb -k
couchdb -b
echo ""
echo ""
echo ""
echo "We will relax while the couch gets ready."
sleep 1
while true; do nc -vz $T_COUCH_HOST 5984 > /dev/null && break; done
echo ""
echo ""
echo ""
echo "CouchDB is ready"
echo ""
echo ""
echo ""
echo "Creating user1 at http://$T_ADMIN:$T_PASS@$T_COUCH_HOST:$T_COUCH_PORT/_users/org.couchdb.user:$T_USER1"
curl -HContent-Type:application/json -vXPUT "http://$T_ADMIN:$T_PASS@$T_COUCH_HOST:$T_COUCH_PORT/_users/org.couchdb.user:$T_USER1" --data-binary '{"_id": "'"org.couchdb.user:$T_USER1"'","name": "'"$T_USER1"'","roles": [],"type": "user","password": "'"$T_USER1_PASSWORD"'"}'
echo ""
echo ""
echo ""
echo "Creating the location list"
curl -XPUT http://$T_ADMIN:$T_PASS@127.0.0.1:5984/tangerine 
curl -XPUT http://$T_ADMIN:$T_PASS@127.0.0.1:5984/tangerine/location-list -d '{"locationsLevels":[]}'
echo ""
echo ""
echo ""
echo "Push the ojai design doc"
cp /tangerine/app/couchapprc.sample /tangerine/app/.couchapprc
sed -i "s#YOUR_ADMIN_USERNAME_HERE#$T_ADMIN#" /tangerine/app/.couchapprc 
sed -i "s#YOUR_PASSWORD_HERE#$T_PASS#" /tangerine/app/.couchapprc 
sed -i "s#YOUR_SERVER#127.0.0.1#" /tangerine/app/.couchapprc 
cd /tangerine/app
watchr file.watchr 
