## Description

nbs-test-webui.sh script will 
* login
* save all needed tokens
* navigate to advanced search
* search for all female patients and check count
* if count is 0 note error, if greater than zero good!

It is a bash script that can be run via cloudshell if NBS is hosted in
AWS or by any system with bash installed.  Curl is the only other
dependency.

## USAGE
nbs-test-webui.sh [-h] [-?] [-d] [-D] [-P] [-H BASE_URL] [-U USER ] [-c count ] 

e.g. ./nbs-test-webui.sh -d -H app.demo.nbspreview.com -U state

## Flags
| Flag | Description |
| -----| ------------------------------------------------------------ | 
| -h | will echo usage |
| -? | will echo usage |
| -d | will turn on debugging |
| -D | will turn on debugging |
| -P | will prompt at each step |
| -H | base host for hitting webui |
| -B | baseurl url for hitting API |
| -U | user in the database with access to create and delete patients |
| -c | count number of iterations, default is 1 |
