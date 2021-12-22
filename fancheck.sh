# THIS IS A WIP PROJECT
# you need to replace some text with values such as IP addresses, usernames and passwords.
# change the fan speed depending on your setup and environment.
# best temperature range for m3x, m3v1 and m3v2 is 79 to 82 degrees,
# highest temperature set to 81 to allow the program to increase the fan speed in time and avoid overheating.

PASSWORD=admin
USERNAME=admin
IP_ADDRESS=192.168.1.100
FAN_CONTROLLER_IP=192.168.1.101
H=81
C=79
P=65
F=2
LF=1
WAIT_TIME=10
# 1 for ON and 0 for OFF
# NOT READY FOR USE
ENABLE_WEB_MODE=1
ENABLE_LOG_TO_FILE=0
#### END OF EDITABLE SECTION ####
echo "──────▄▀▄─────▄▀▄"
echo "─────▄█░░▀▀▀▀▀░░█▄"
echo "─▄▄──█░░░░░░░░░░░█──▄▄"
echo "█▄▄█─█░░▀░░┬░░▀░░█─█▄▄█ Nya~"
echo "================================================="
echo "=            + +  Configuration  + +            ="
echo "================================================="
echo "Hashboard temp trigger (HOT) = $H"
echo "Hashboard temp trigger (COLD) = $C"
echo "PSU temp trigger = $P"
echo "Fan speed (HIGH) = $F"
echo "Fan speed (LOW) = $LF"
echo "Sleep time set to $WAIT_TIME seconds"
echo "ASIC Miner IP address = $IP_ADDRESS"
echo "Fan controller IP address = $FAN_CONTROLLER_IP"
if [ $ENABLE_LOG_TO_FILE -eq 1 ]
then
echo "Log to file is ENABLED"
else
echo "Log to file is DISABLED"
fi
if [ $ENABLE_WEB_MODE -eq 1 ]
then
echo "Web monitor interface is ENABLED"
else
echo "Web monitor interface is DISABLED"
fi
echo "================================================="
echo "=               Starting the bot                ="
echo "================================================="
sleep 5
for (( ; ; ))
do
sshpass -p $PASSWORD ssh -t $USERNAME@$IP_ADDRESS 'sensors -u' >> /tmp/temp
sed -i 's/: /=/' /tmp/temp
sed '/temp1_input=/!d' /tmp/temp >> /tmp/temp1
rm /tmp/temp
cat /tmp/temp1 | sed 's/  temp1_input=//g' >> /tmp/temp
rm /tmp/temp1
sed -i 's/\..*//' /tmp/temp
sed -i 's/\(.*\)/"\1"/g' /tmp/temp
sed -i '1s/^/T1=/' /tmp/temp
sed -i '2s/^/T2=/' /tmp/temp
sed -i '3s/^/T3=/' /tmp/temp
source /tmp/temp
if [ $T1 -ge $H ] || [ $T2 -ge $H ] || [ $T3 -ge $H ]
    then
        echo "temp is greater than $H"
        echo "turning fan speed to $F"
        wget -qO- http://$FAN_CONTROLLER_IP/$F &> /dev/null
    elif [ $T1 -le $C ] && [ $T2 -le $C ] && [ $T3 -le $C ]
    then
	echo "System is running cold (Lower then $C)"
	echo "Turning down the fan speed to $LF"
	wget -qO- http://$FAN_CONTROLLER_IP/$LF &> /dev/null
	echo "Hashboard 1: $T1"
        echo "Hashboard 2: $T2"
        echo "Hashboard 3: $T3"
    else
	echo "Hashboard Temp is OK"
	echo "Hashboard 1: $T1"
	echo "Hashboard 2: $T2"
	echo "Hashboard 3: $T3"
fi
PSUT="`wget -qO- http://$FAN_CONTROLLER_IP/temperaturec`"
echo "$PSUT" > /tmp/psu
sed -i 's/\..*//' /tmp/psu
sed -i 's/\(.*\)/"\1"/g' /tmp/temp
sed -i '1s/^/T4=/' /tmp/psu
source /tmp/psu
if [ $T4 -ge $P ]
    then
        echo "PSU OVERHEATING! $T4"
        echo "Turning fan speed to full"
        wget -q0- http://$FAN_CONTROLLER_IP/4 &> /dev/null
        # replace with any warning system you have, or if you're using a PMS, add the command to turn the entire system off.
    else
        echo "PSU Temp is OK"
	echo "PSU Temp: $T4"
fi

# clean up
sync; echo 3 > /proc/sys/vm/drop_caches 
rm /tmp/tem*
rm /tmp/psu
# end of clean up
echo "waiting for $WAIT_TIME seconds"
sleep $WAIT_TIME
done
