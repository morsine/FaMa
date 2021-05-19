# you need to replace some text with values such as IP addresses, usernames and passwords.
sshpass -p SSH_PASSWORD ssh -t USERNAME@IP_ADDRESS 'sensors -u' >> /tmp/temp
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
if [ $T1 -ge 80 ] || [ $T2 -ge 80 ] || [ $T3 -ge 80 ]
    then
        echo "temp is greater than 80"
        echo "turning fan speed to 4"
        wget -qO- http://ESP8266_IPADDRESS/4 &> /dev/null
    else
        echo "Temp is OK $T1 $T2 $T3"
fi
PSUT="`wget -qO- http://ESP8266_IPADDRESS/temperaturec`"
echo "$PSUT" > /tmp/psu
sed -i 's/\..*//' /tmp/psu
sed -i 's/\(.*\)/"\1"/g' /tmp/temp
sed -i '1s/^/T4=/' /tmp/psu
source /tmp/psu
if [ $T4 -ge 72 ]
    then
        echo "PSU OVERHEATING!"
        # Trigger whatever you have which turns off the specific rig
    else
        echo "PSU Temp is OK $T4"
fi
echo removing files
rm /tmp/tem*
rm /tmp/psu
