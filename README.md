# md5check - File Integrity Checker

## Running the script
 - $ chmod u+x md5check.sh
 - $ touch .md5sum.db md5check.files
 - $ echo -e "/path/to/file/to_be_monitored\n/path/to/file2/\n..." md5check.files
 - $ ./md5check.sh generate

## Script Options and Sample Output
 - # ./md5check.sh show-changed<br />Calculating Changes...Please Wait...
 - # ./md5check.sh show-all<br />Calculating Changes...Please Wait...<br />/etc/passwd has not been modified
 - # ./md5check.sh show-verbose<br />Calculating Changes...Please Wait...<br />/etc/passwd has not been modified (Current: c15e9a95ceff9b444e8edce7fe464da7)

## Contributors
  - Justin Wray (Synister Syntax)
