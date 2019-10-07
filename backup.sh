export LOGDIR=/home/sshweb/backup

mkdir -p ${LOGDIR}/$(date +%w)
rm "${LOGDIR}/$(date +%w)/*" > /dev/null 2>&1
rm "${LOGDIR}/$(date +%w)/*" > /dev/null 2>&1

SERVER="localhost"
USER="root"
PASS="***"

databases=`mysql --user=$USER --password=$PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --force --opt --user=$USER --password=$PASS --databases $db > ${LOGDIR}/$(date +%w)/$(date +%F).$db.sql
    fi
done

# some files
cp -R /home/sshweb/www/shaarli.fam-martel.eu/data ${LOGDIR}/$(date +%w)/$(date +%F)-shaarli




# archive
tar -zcvf ${LOGDIR}/$(date +%w).tar.gz ${LOGDIR}/$(date +%w)/

cp ${LOGDIR}/$(date +%w).tar.gz /mnt/backupftp/$(date +%w).tar.gz
