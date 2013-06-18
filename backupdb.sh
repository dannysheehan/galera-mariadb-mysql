# -------------------------------------------------------------------
# Simple script to do full database backup for INNODB databases.
# It also does an offsite backup to google drive.
#
# Need to setup daily cron job
#   54 4 * * * /root/scripts/backupdb.sh | /usr/bin/mail -s "backup" root
#
#  Assumes /root/.my.cnf is configured for passwordless access to mysql.
#
# See following for setting up Google Drive offsiting of backups.
#  - http://petermolnar.eu/linux-tech-coding/database-backups-to-google-drive/
#
# BY: Danny Sheehan  http://www.setuptips.com
# -------------------------------------------------------------------

GDRIVE="/GDRIVE"
BKUP_DIR="${GDRIVE}/MYSQL"

# your secret encryption password.
PASSWDFILE="/root/enc-password.txt"

# Number of days to retain backups for.
RETENTION_DAYS=7

# Encryption algorithm.
ENCALGO="aes-128-cbc"

# Set to 0 if you do not have gdrive backups configured.
GRIVEENABLED=1

if [ ! -d "${BKUP_DIR}" ]
then
  echo "$BKUP_DIR does not exist"
  exit 1
fi

echo "START: `date`"

#
# clean up after RETENTION days.
#
find $BKUP_DIR -name "*.sql.gz.enc" -mtime +${RETENTION_DAYS} -exec rm {} \;

DATABASES=`mysql -Bse 'show databases;'`

for DB in $DATABASES
do

  # Skip system tables
  if [ "$DB" = "information_schema" -o \
       "$DB" = "performance_schema" -o \
       "$DB" = "mysql" ]
  then 
    continue
  fi

  # Dump database
  BKUP_FILE="${BKUP_DIR}/${DB}.`/bin/date +\%Y\%m\%d`.sql.gz"

  # For InnoDB single-transaction is recommended.
  mysqldump --single-transaction ${DB} | gzip -9 > ${BKUP_FILE}

  echo
  echo "backup file checksum is `sum ${BKUP_FILE}`"

  # Encrypt database
  openssl ${ENCALGO} \
      -in ${BKUP_FILE} \
      -out ${BKUP_FILE}.enc \
      -pass file:$PASSWDFILE

  rm ${BKUP_FILE}
  echo "To decrpyt -> openssl aes-128-cbc -d -in ${BKUP_FILE}.enc | gunzip -9"

done

echo
echo "END: `date`"


echo "To decrpyt -> openssl ${ENCALGO} -d -in <file>.enc | gunzip -9" > $BKUP_DIR/README.txt

if [ "$GRIVEENABLED" -ne 0 ]
then
  echo
  echo "offsite backup enabled"
  cd $GDRIVE
  grive
fi
