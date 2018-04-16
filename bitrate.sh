#! /bin/bash

file="results.ods"
if [ -f "$file" ]
then
	rm $file
fi
sudo service snmpd start
printf "%s\t" "Previous IfInOctets" "Current IfInOctets" "Time" "Bitrate" | paste -sd '\t' >> kvm.ods
starttime=`date +%s%N`

t=0
c=0
maxCounter=4294967295
octet=8
timeinterval=60

previousifInOctets=`snmpwalk -c public -v 2c 192.168.122.90 1.3.6.1.2.1.2.2.1.10 | grep ifInOctets.2 | awk '{ print $4 }'`

endtime=`date +%s%N`
sleeptime=`expr $endtime - $starttime`


time=`echo "scale=9 ; $sleeptime/1000000000" | bc`
timenano=`echo "scale=9 ; $timeinterval-$time" | bc`
sleep $timenano
t=$(( $t + $timeinterval ))
currentifInOctets=`snmpwalk -c public -v 2c 192.168.122.90 1.3.6.1.2.1.2.2.1.10 | grep ifInOctets.2 | awk '{ print $4 }'`

while [ $c -le 10 ]
do
	loopstarttime=`date +%s%N`
	
	if [ $previousifInOctets -gt $currentifInOctets ]
	then
		currentifInOctets=$(( $currentifInOctets + $maxCounter ))
	fi

	avgbitrate=`expr $currentifInOctets - $previousifInOctets` #calculate octet difference in the timeinterval
	avgbitrate=$(( $avgbitrate * $octet )) #converting the octets to bits
	avgbitrate=$(( $avgbitrate / $timeinterval )) #finding avg bitrate in bps by dividing with time interval
	avgbitrate=`echo "scale=2 ; $avgbitrate/1024" | bc` #bps to kbps

	printf "%d\t%d\t%d\t%.2f\t" $previousifInOctets $currentifInOctets $t $avgbitrate | paste -sd '\t' >> kvm.ods

	previousifInOctets=$currentifInOctets
	loopendtime=`date +%s%N`
	loopsleeptime=`expr $loopendtime - $loopstarttime`
	
	looptime=`echo "scale=9 ; $loopsleeptime/1000000000" | bc`
	looptimenano=`echo "scale=9 ; $timeinterval-$looptime" | bc`
	sleep $looptimenano

	currentifInOctets=`snmpwalk -c public -v 2c 192.168.122.90 1.3.6.1.2.1.2.2.1.10 | grep ifInOctets.2 | awk '{ print $4 }'`
	c=$(( $c + 1 ))
	t=$(( $t + $timeinterval ))
done

sudo service snmpd stop
