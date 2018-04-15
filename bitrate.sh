#! /bin/bash

starttime=`date +%s%N`

c=0
maxCounter=4294967295
octet=8
timeinterval=10

endtime=`date +%s%N`

sleeptime=`expr $endtime - $starttime`
echo $sleeptime
time=`echo "scale=9 ; $sleeptime/1000000000" | bc`
echo $time
echo "sleeping"
time2=`echo "scale=9 ; $timeinterval-$time" | bc`
echo $time2

#sudo service snmpd start
#currentifInOctets=`snmpwalk -c public -v 2c localhost 1.3.6.1.2.1.2.2.1.10 | grep ifInOctets.3 | awk '{ print $4 }'`
