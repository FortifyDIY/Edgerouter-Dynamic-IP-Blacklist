#Backup previous list
 rm -f BLACKLIST_OLD.txt
 mv BLACKLIST.txt BLACKLIST_OLD.txt
touch BLACKLIST.txt

#Download the file from PGL.YOYO
curl -O http://pgl.yoyo.org/as/iplist.php
#Download the file from emerging threats
curl -O http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
#Download the first file from SpamHaus
curl -O http://www.spamhaus.org/drop/drop.txt
#Download the second file from SpamHaus
curl -O http://www.spamhaus.org/drop/edrop.txt
#Download the file from okean Korea
curl -O http://www.okean.com/sinokoreacidr.txt
#Download the file from okean China
curl -O http://www.okean.com/chinacidr.txt
#Download file from myip
curl -O http://www.myip.ms/files/blacklist/general/latest_blacklist.txt
#Download file from Blocklist.de
curl -O http://lists.blocklist.de/lists/all.txt
#Download bogon blacklist from cymru.org
curl -O http://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt
#Download blacklist from Cisco/Talos
curl -L https://www.talosintelligence.com/documents/ip-blacklist >> ip-blacklist.txt

#Combine lists into one file
cat all.txt \
 drop.txt \
edrop.txt \
 iplist.php \
sinokoreacidr.txt \
 chinacidr.txt \
 latest_blacklist.txt \
LocalBlacklist.txt \
fullbogons-ipv4.txt \
 ip-blacklist.txt \
emerging-Block-IPs.txt > PreliminaryOutput.txt

#Strip out everything except for the IPV4 addresses
 sed -e '/^#/ d' \
 -e '/[:]/ d' \
-e 's/ .*// g' \
-e 's/[^0-9,.,/]*// g' \
-e '/^$/ d' < PreliminaryOutput.txt > PreUniqueOutput.txt

#Count the number of ip's
sed -n '$=' PreUniqueOutput.txt

#Remove any duplicates
sort PreUniqueOutput.txt | uniq -u > PreBlacklist.txt

#Remove any whitelisted ip's from LocalWhitelist.txt
sort PreBlacklist.txt > PreBL.sort
sort LocalWhitelist.txt > LocalWL.sort
comm -23
PreBL.sort LocalWL.sort
> BLACKLIST.txt

#Remove any preliminary files
rm Pre*

#Do a final count
sed -n '$=' BLACKLIST.txt

####trying to incorporate old list
getnetblocks() {
cat <<EOF

# Generated by ipset
-N geotmp nethash --hashsize 1024 --probes 4 --resize 20
EOF
 cat /config/blacklist/BLACKLIST.txt|egrep '^[0-9]'|egrep '/' |sed -e "s/^/-A geotmp /"
}
 getnetblocks > /config/blacklist/netblock.txt
 sudo ipset -! -R < /config/blacklist/netblock.txt
 sudo ipset -W geotmp ET-N
 sudo ipset -X geotmp
getaddblocks() {
cat <<EOF

# Generated by ipset
-N geotmp nethash --hashsize 1024 --probes 4 --resize 20
EOF
 cat /config/blacklist/BLACKLIST.txt|egrep '^[0-9]'|egrep -v '/' |sed -e "s/^/-A geotmp /"
 }
 getaddblocks > /config/blacklist/addblock.txt
 sudo ipset -! -R < /config/blacklist/addblock.txt
 sudo ipset -W geotmp ET-A
 sudo ipset -X geotmp
rm /config/blacklist/addblock.txt
 rm /config/blacklist/netblock.txt

# Remove faulty network(s)
ipset del ET-N 0.0.0.0/1 -exist 
