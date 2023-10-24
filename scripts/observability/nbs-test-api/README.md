## Description

nbs-test-api.sh script will 
* create a patient
* search for the patient
* delete that patient (note record still exists but is inactive)

nbs-test-api-insert-errors.sh will do the same but will also run some
badly formatted requests to generate some errors in observability consoles.

It is a bash script that can be run via cloudshell if NBS is hosted in
AWS or by any system with bash installed.  Curl is the only other
dependency.

## USAGE
nbs-test-api.sh [-h] [-?] [-d] [-D] [-P] [-B BASE_URL] [-U USER ] [-c count ] 

## Flags
| Flag | Description |
| -----| ------------------------------------------------------------ | 
| -h | will echo usage |
| -? | will echo usage |
| -D | will turn on debugging |
| -d | will turn on debugging |
| -P | will prompt at each step |
| -B | baseurl url for hitting API |
| -U | user in the database with access to create and delete patients |
| -c | count number of iterations, default is 1 |
