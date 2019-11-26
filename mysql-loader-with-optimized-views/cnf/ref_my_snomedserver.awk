# Adds or replaces the defaults-file reference in the MySQL file
# /Library/LaunchDaemons/com.oracle.oss.mysql.mysqld.plist
# So that this references the file /usr/local/mysql/support-files/my_snomedserver.cnf
!/<string>--defaults-file=.*<.string>/ {print $0 }
/<.?array>/ {counter=counter+1 } 
/<string>.usr.local.mysql.bin.mysqld<.string>/ {if (counter == 1) { print "		<string>--defaults-file=/usr/local/mysql/support-files/my_snomedserver.cnf</string>" }}
