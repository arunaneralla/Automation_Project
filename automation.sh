apt update -y
dpkg-query -s apache2 > /dev/null 2>&1
if [[ $? -eq '0' ]] ; then
 echo "apache2 is already installed."
else
 echo "Apache2 is not installed. Installing now"
 apt-get install apache2
fi
systemctl status apache2 > /dev/null 2>&1
if [[ $? -eq '0' ]] ; then
 echo "apache2 is running"
else
 echo "apache2 is not running. Starting now"
 systemctl start apache2
fi
systemctl list-unit-files --state=enabled | grep apache2.service > /dev/null 2>&1
if [[ $? -eq '0' ]] ; then
 echo "apache2 is enabled"
else
 echo "Apache2 is not Enabled. Enabling now"
 systemctl enable apache2
fi 
#calculating timestamp
timestamp=$(date '+%d%m%Y-%H%M%S')
echo "Timestamp is $timestamp"
myname=Aruna
s3_bucket=upgrad-aruna
tar_file_name=${myname}-httpd-logs-${timestamp}.tar
echo "Tar file name is ${tar_file_name}"
find /var/log/apache2/ -name "*.log" | tar -cf /tmp/${tar_file_name} -T -
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
tar_file_size=$(wc -c <"/tmp/${tar_file_name}")
FILE=/var/www/html/inventory.html
if [[ -f "$FILE" ]]; then
 echo "$FILE exists."
 echo -e "httpd-logs \t$timestamp \ttar \t${tar_file_size}" >> /var/www/html/inventory.html
else
 echo "$FILE doesn't exists. Creating new with header."
 echo -e "Log Type \tTime Created \t\tType \tSize" >> /var/www/html/inventory.html
 echo -e "httpd-logs \t$timestamp \ttar \t${tar_file_size}" >> /var/www/html/inventory.html
fi
cronfile=/etc/cron.d/automation
if [[ -f "$cronfile" ]]; then
 echo "Cron Job already exists/scheduled"
else
 echo "Cron Job not exist/Scheduled, Creating a cron job now"
 echo "* * * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi
