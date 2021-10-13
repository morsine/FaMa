# you need to replace some text with values such as IP addresses, usernames and passwords.
for (( ; ; ))
do
sshpass -p PASSWORD ssh -t USERNAME@IP_ADDRESS 'sensors -u' >> /tmp/temp
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
if [ $T1 -ge 76 ] || [ $T2 -ge 76 ] || [ $T3 -ge 76 ]
    then
        echo "temp is greater than 76"
        echo "turning fan speed to 4"
        wget -qO- http://FAN_CONTROLLER_IP/4 &> /dev/null
    else
	echo "Hashboard Temp is OK"
        echo "Hashboard 1: $T1"
	echo "Hashboard 2: $T2"
	echo "Hashboard 3: $T3"
fi
PSUT="`wget -qO- http://FAN_CONTROLLER_IP/temperaturec`"
echo "$PSUT" > /tmp/psu
sed -i 's/\..*//' /tmp/psu
sed -i 's/\(.*\)/"\1"/g' /tmp/temp
sed -i '1s/^/T4=/' /tmp/psu
source /tmp/psu
if [ $T4 -ge 65 ]
    then
        echo "PSU OVERHEATING! $T4"
        echo "Turning fan speed to full"
        wget -q0- http://FAN_CONTROLLER_IP/4 &> /dev/null
        # replace with any warning system you have, or if you're using a PMS, add the command to turn the entire system off.
    else
        echo "PSU Temp is OK"
	echo "PSU Temp: $T4"
fi
echo cleaning up...
sync; echo 3 > /proc/sys/vm/drop_caches 
rm /tmp/tem*
rm /tmp/psu
echo waiting
sleep 30
done
