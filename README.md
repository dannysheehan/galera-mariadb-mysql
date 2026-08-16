> **Archived.** These scripts are from 2013–2014, for the same tuxlite LAMP cluster as [djbdns-tinydns](https://github.com/dannysheehan/djbdns-tinydns) and [lsyncd](https://github.com/dannysheehan/lsyncd). The Galera cluster files (`galera-tune.cnf`, `galera-ufw`) were deleted in November 2014. What remains is a backup helper and a MyISAM→InnoDB dump rewrite.
>
> That is not a good 2026 setup:
> - This is not a Galera how-to. [MariaDB still ships Galera](https://mariadb.com/kb/en/galera-cluster/) in the community server; Codership's MySQL Galera builds [EOL 30 September 2026](https://mariadb.com/resources/blog/upgrade-now-announcing-mysql-galera-cluster-in-place-migration-to-mariadb-galera-cluster/). Use current MariaDB or Percona XtraDB Cluster docs, not these files.
> - `backupdb.sh` dumps with `mysqldump --single-transaction`, encrypts with OpenSSL `aes-128-cbc`, and offsits with [grive](https://github.com/vitalif/grive2), an unofficial Drive client. Use mariabackup/xtrabackup and a current object-store tool.
> - `myisam2innodb.pl` comments out FULLTEXT and rewrites `ENGINE=MyISAM` in a dump. Galera still requires InnoDB; you would not start from MyISAM today.
>
> Left here as a historical leftover from that cluster.

# galera-mariadb-mysql

## backupdb.sh

Daily cron helper. Skips `mysql` / `information_schema` / `performance_schema`, gzip-dumps each other database, encrypts, keeps 7 days under `/GDRIVE/MYSQL`, then runs `grive`. Assumes `/root/.my.cnf` and `/root/enc-password.txt`.

```
54 4 * * * /root/scripts/backupdb.sh | /usr/bin/mail -s "backup" root
```

Decrypt: `openssl aes-128-cbc -d -in <file>.enc | gunzip -9`

## myisam2innodb.pl

Rewrites a `mysqldump` so tables become InnoDB and FULLTEXT keys are commented out (InnoDB did not support them then).

```
mysqldump -u root -p --add-drop-table --databases db1 db2 > backup.sql
myisam2innodb.pl backup.sql > converted.sql
mysql -u root -p < converted.sql
```

Last real change November 2014 (cluster config removed).
