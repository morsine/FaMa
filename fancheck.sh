# Replace the values below
# ASIC Miner SSH username
PASSWORD=admin
# ASIC Miner SSH password
USERNAME=admin
# ASIC Miner IP Address
IP_ADDRESS=192.168.1.100
# Fan controller IP address
FAN_CONTROLLER_IP=192.168.1.200
# Trigger temp for the hashboards
H=76
# Trigger temp for the PSU
P=65
# Fan speed to set
F=4
# Time between rechecking the system
WAIT_TIME=15
# ----------------------------------
echo "Configuration"
echo "Hashboard temp trigger = $H"
echo "PSU temp trigger = $P"
echo "Fan speed to set = $F"
echo "Sleep time set to $WAIT_TIME"
echo "ASIC Miner IP address = $IP_ADDRESS"
echo "Fan controller IP address = $FAN_CONTROLLER_IP"
# --- end of editable variables ---
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
echo cleaning up...
sync; echo 3 > /proc/sys/vm/drop_caches 
rm /tmp/tem*
rm /tmp/psu
echo "waiting for $WAIT_TIME seconds"
sleep $WAIT_TIME
done
