#!/usr/bin/perl
# ---------------------------------------------------------------------
# Converts database from MyISAM to InnoDB table format by updating the 
# mysqldump ouutput fule.
#  - FULLTEXT KEY's are also removed as they are not supported by InnoDB.
#
# USAGE:
#   mysqldump -u root -p<psswd-here> --add-drop-table \
#          --databases <db1> <db2> ... > backup.sql
#   myisam2innodb.pl backup.sql > converted.sql
#
#   mysql -u root -p<psswd-here> < converted.sql
#
# BY:  Danny Sheehan   http://www.setuptips.com
# ---------------------------------------------------------------------

undef $/;
$_ = <>;

# s/,\n\)/\n\)/gs;
s/\n\) ENGINE=MyISAM/\n\) ENGINE=InnoDB/gs;
s/,\n  FULLTEXT KEY /\n-- FULLTEXT KEY /gs;

print "$_";
