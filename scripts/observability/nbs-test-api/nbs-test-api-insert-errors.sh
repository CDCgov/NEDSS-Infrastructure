#!/bin/bash

##########################################################################
#
#  $Id: single_script.sh,v 1.6 2023/10/16 17:54:19 mossc Exp mossc $
#
#  Description: This script logs into nbs, creates a Patient, searches a
#  Patient
#  and then deletes the Patient, we should create a readonly version
#
#  Args:        $1 is 
#               $2 is 
#
#  Called by: 
#  Calls:
#
#  TODO: 1.
#        2.
#
##########################################################################

COUNT=1
# DEBUG ON
#DEBUG=1


##########################################################################
# Set variables

# base is the basename of this script
BASE=`basename $0`

# Minimum number of args
MINARGS=2

# list of options available to this script
# options requiring arguments must be followed by a ":"
# search for X,Y and Z and replace with appropriate options
OPTLIST=dDPc:U:B:h?

# Usage variable is echoed if the argument checks fail or 
# the -? or -h option is passed
USAGE="USAGE: $BASE [-h] [-?] [-d] [-D] [-P] [-B BASE_URL] [-U USER ] [-c count ] \n\
Where -h or -? will echo this usage \n\
Where -D or -d  will turn on debugging \n\
Where -P will prompt at each step \n\
Where -B baseurl url for hitting API \n\
Where -U user in the database with access to create and delete patients \n\
Where -c count number of iterations, default is 1 \n\

"

if [ $DEBUG ]; then echo "DEBUG on"; fi
 

##########################################################################
# Check for correct number of arguments

if [ $# -lt "$MINARGS" ]
then
	echo "Insufficient arguments "
        echo -e $USAGE
        echo " "
        echo ""
        exit 1
fi

##########################################################################

##########################################################################
# Read options

while getopts $OPTLIST c
do
	case $c in

		# single flags
        D | d)  DEBUG=1
                        echo "DEBUG flag on";;
		P)  PROMPT=true
			echo "PROMPT=${PROMPT}";;

		# options that take arguments
		U)  LOGIN_USER=$OPTARG
			echo LOGIN_USER=$LOGIN_USER;;

		B)  BASE_URL=$OPTARG
			echo BASE_URL=$BASE_URL;;

		c)  COUNT=$OPTARG
			echo COUNT=$COUNT;;

		# usage request or bad usage
		h | \?)    echo -e $USAGE
			#echo question
			#echo FLAG=$c
			exit 2;;

        esac
done

##########################################################################
# Begin logic

login_nbs()
{
    TMP_URL=$1
    TMP_USER=$2

    curl -q -X "POST" "${TMP_URL}/login" \
        -H 'Content-Type: application/json' \
        --silent \
        -d $'{
    "username": "'"${TMP_USER}"'"
    }'
}
login_nbs_error()
{
    TMP_URL=$1
    TMP_USER=$2

    curl -q -X "POST" "${TMP_URL}/login" \
        -H 'Content-Type: application/json' \
        --silent \
        -d $'{
    "badfieldtogenerateerrors": "'"${TMP_USER}"'"
    }'
}

patient_create()
{
    TMP_URL=$1
    TMP_TOKEN=$2

    curl -X "POST" "${TMP_URL}/graphql" \
        -H "Authorization: Bearer ${TMP_TOKEN}" \
        --silent \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d $'{
	    "query": "mutation create($patient:PersonInput!){createPatient(patient:$patient){id shortId}}",
	    "variables": {
		    "patient": {
			    "comments": "Created for Development testing",
			    "asOf": "2023-10-06T18:14:23+00:00",
			    "names": [
				    {
					    "use": "L",
					    "first": "Aya",
					    "last": "Brea"
				    }
			    ]
		    }
	    }
    }'
}

patient_search ()
{
    ## Patient Search(7.0.0)
    TMP_URL=$1
    TMP_TOKEN=$2
    curl -X "POST" "${TMP_URL}/graphql" \
        --silent \
        -H "Authorization: Bearer ${TMP_TOKEN}" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d $'{
	    "query": "query search($filter:PersonFilter!,$page:SortablePage){findPatientsByFilter(filter:$filter,page:$page){content{id shortId names{firstNm middleNm lastNm}}total}}",
	    "variables": {
		    "filter": {
			    "lastName": "brea",
			    "recordStatus": [
				    "ACTIVE"
			    ]
		    },
		    "page": {
			    "pageNumber": 0,
			    "pageSize": 25,
			    "sortDirection": "ASC",
			    "sortField": "lastNm"
		    }
	    }
    }'
}

patient_delete()
{
    ## Delete
    TMP_URL=$1
    TMP_TOKEN=$2
    TMP_PATIENT_ID=$3
    #curl -X "POST" "http://localhost:8080/graphql" \
    # "patient": "10061299"
    curl -X "POST" "${TMP_URL}/graphql" \
        -H "Authorization: Bearer ${TMP_TOKEN}" \
        --silent \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d $'{
	    "query": "mutation deletePatient($patient:ID!){deletePatient(patient:$patient){__typename ... on PatientDeleteFailed{patient reason}... on PatientDeleteSuccessful{patient}}}",
	    "variables": {
		    "patient": '"${TMP_PATIENT_ID}"'
	    }
    }'
}

# BEGIN actual work

X=$COUNT;
# repeat a command X times

echo "running process ${COUNT} times"
while [ $X -gt 0 ]
do

            echo "REMAINING PASSES $X"
            Y=$(($X-1))

            echo "##################################################################################################################################"
            echo "logging in and fetching token"
            #echo  login_nbs ${BASE_URL} ${LOGIN_USER} 
            #TMP_TOKEN=$(login_nbs ${BASE_URL} ${LOGIN_USER} | jq -r .token)
            TMP_TOKEN=$(login_nbs_error ${BASE_URL} ${LOGIN_USER} | jq -r .token)
            echo "RETURN_CODE=$?"
            echo TMP_TOKEN=${TMP_TOKEN}
            echo 
            
            echo "#################################################################"
            echo "now creating patient with last name Brea"
            echo "capture ID for later use"
            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
            
            #echo patient_create.sh ${BASE_URL} ${TMP_TOKEN}
            #TMP_PATIENT_ID=$(./Patient/Create.sh ${BASE_URL} ${TMP_TOKEN} |  jq -r .data.createPatient.id)
            TMP_PATIENT_ID=$(patient_create ${BASE_URL} ${TMP_TOKEN} |  jq -r .data.createPatient.id)
            echo "RETURN_CODE=$?"
            echo "Patient with last name Brea created with Patient ID = ${TMP_PATIENT_ID}"
            echo
            

            echo "#################################################################"
            echo "now searching patient with last name Brea"
            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
            if patient_search ${BASE_URL} ${TMP_TOKEN} | grep "error" 
            then
                echo "ERROR:  searching for Patient"
            else
                echo "NOTICE: Patient found, good!"
            fi
            echo
            
            
            echo "#################################################################"
            echo "now deleting patient with last name Brea and patient id ${TMP_PATIENT_ID}"
            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
            #echo patient_delete.sh ${BASE_URL} ${TMP_TOKEN} ${TMP_PATIENT_ID}
            patient_delete ${BASE_URL} ${TMP_TOKEN} ${TMP_PATIENT_ID} | jq
            echo "RETURN_CODE=$?"
            echo
            echo "#################################################################"
                        

            X=$Y

done
