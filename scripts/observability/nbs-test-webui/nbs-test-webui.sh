#!/bin/bash

##########################################################################
#
#  Description: This script logs into nbs via webui 
#               navigates to advanced search
#               searches for all Female patients and returns count
#  TODO: cleanup debug
#           add more descriptions of what each curl command is doing
#           wrap output in a prompt/sleep option
#
##########################################################################

# DEBUG ON
#DEBUG=1
#CURL='curl -q --silent --write-out "%{http_code}"' 
CURL='curl -q --silent'
COOKIE_JAR=cookie-jar.$$
SEARCH_RESULTS=search_results.$$


##########################################################################
# Set variables

# base is the basename of this script
BASE=`basename $0`

# Minimum number of args
MINARGS=2

# list of options available to this script
# options requiring arguments must be followed by a ":"
# search for X,Y and Z and replace with appropriate options
OPTLIST=dDp:PU:H:h?

# Usage variable is echoed if the argument checks fail or 
# the -? or -h option is passed
USAGE="USAGE: $BASE [-h] [-?] [-d] [-D] [-P] [-H <HOST> ] [-U USER ] [-p <password> ] \n\
Where -h or -? will echo this usage \n\
Where -D or -d  will turn on debugging \n\
Where -P will prompt at each step \n\
Where -p will take password at cli NOT RECOMMENDED! \n\
Where -H base host for hitting webui \n\
Where -U user in the database with access to search patients \n\

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

		H)  TMP_HOST=$OPTARG
            BASE_URL="https://${TMP_HOST}"
            echo BASE_URL=${BASE_URL}
			echo TMP_HOST=$TMP_HOST;;

		p)  TMP_PASS=$OPTARG
			echo TMP_PASS=$TMP_PASS;;

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
    TMP_PASS=$3

    echo
    read -p "load login page, Press enter to continue..."  junk
    echo
    # load the login page, does this set a cookie?
    ${CURL} "${TMP_URL}/nbs/login" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: no-cache' \
    -H 'pragma: no-cache' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --compressed
    
    RETURN_CODE=$?
    if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi
    echo 
    
    ####################################################################################################
    # start the actual login post - user and password included
    echo
    read -p "start login, Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/nbs/nbslogin" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H "origin: ${BASE_URL}" \
    -H "referer: ${BASE_URL}/nbs/login" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw "mode=&ObjectType=&OperationType=&PopupDataResult=&UserName=${TMP_USER}&Password=${TMP_PASS}" \
    --compressed
    #--data-raw 'mode=&ObjectType=&OperationType=&PopupDataResult=&UserName=state&Password=badpass' \
    
    echo
    read -p "second login url Press enter to continue..."  junk
    echo
    # next get
    ${CURL} "${TMP_URL}/nbs/nfc?UserName=${TMP_USER}" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H "referer: ${BASE_URL}/nbs/login" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --compressed

    echo
    read -p "third login url loadhome page, Press enter to continue..."  junk
    echo
    # last document get as part of login
    ${CURL} "${TMP_URL}/nbs/HomePage.do?method=loadHomePage" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H "referer: ${BASE_URL}/nbs/login" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --compressed
}

goto_advanced_search()
{
    TMP_URL=$1
    TMP_TOKEN=$2

    ####################################################################################################
    # now click on advanced search
    # this gets a few cookies
    # Set-Cookie: nbs_user=${TMP_USER}; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; Secure
    # Set-Cookie: JSESSIONID=blahblah; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; HttpOnly
    # Set-Cookie: nbs_token=blah.blah.blah; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; Secure

    # --output /dev/null \
    echo
    read -p "Post AS1 Press enter to continue..."  junk
    echo

    ${CURL} "${TMP_URL}/nbs/MyTaskList1.do?ContextAction=GlobalPatient" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "referer: ${BASE_URL}/nbs/HomePage.do?method=loadHomePage" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --compressed
    
    echo

    if $(grep nbs_token ${COOKIE_JAR} > /dev/null)
    then 
        echo "NOTICE: nbs token found login successful"
        TMP_BEARER_TOKEN=`grep nbs_token ${COOKIE_JAR} | awk '{print $7}'`
        echo TMP_BEARER_TOKEN=${TMP_BEARER_TOKEN}
    else 
        echo "ERROR: nbs token not found login failed"
        exit 1
    fi

    
    echo
    read -p "AS2 Post gets bearer? Press enter to continue..."  junk
    echo
    # this uses those cookies
    ${CURL} "${TMP_URL}/advanced-search" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "referer: ${BASE_URL}/nbs/HomePage.do?method=loadHomePage" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --compressed
}

patient_search ()
{
    TMP_URL=$1
    TMP_TOKEN=$2

    echo
    read -p "S1 Post needs Bearer Press enter to continue..."  junk
    echo

    ${CURL} "${TMP_URL}/encryption/encrypt" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: application/json' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H "referer: ${BASE_URL}/advanced-search" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"recordStatus":["ACTIVE"],"gender":"F"}' \
    --compressed
    
    echo
    TMP_BEARER_TOKEN=`grep nbs_token ${COOKIE_JAR} | awk '{print $7}'`
    echo TMP_BEARER_TOKEN=${TMP_BEARER_TOKEN}
    
    echo
    read -p "Post S2 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllProgramAreas","variables":{},"query":"query findAllProgramAreas($page: Page) {\n  findAllProgramAreas(page: $page) {\n    id\n    progAreaDescTxt\n    nbsUid\n    statusCd\n    statusTime\n    codeSetNm\n    codeSeq\n    __typename\n  }\n}"}' \
    --compressed ;
    
    echo
    read -p "Post S3 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllConditionCodes","variables":{},"query":"query findAllConditionCodes($page: Page) {\n  findAllConditionCodes(page: $page) {\n    id\n    conditionDescTxt\n    __typename\n  }\n}"}' \
    --compressed ;
    

    echo
    read -p "Post S4 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllJurisdictions","variables":{},"query":"query findAllJurisdictions($page: Page) {\n  findAllJurisdictions(page: $page) {\n    id\n    typeCd\n    assigningAuthorityCd\n    assigningAuthorityDescTxt\n    codeDescTxt\n    codeShortDescTxt\n    effectiveFromTime\n    effectiveToTime\n    indentLevelNbr\n    isModifiableInd\n    parentIsCd\n    stateDomainCd\n    statusCd\n    statusTime\n    codeSetNm\n    codeSeqNum\n    nbsUid\n    sourceConceptId\n    codeSystemCd\n    codeSystemDescTxt\n    exportInd\n    __typename\n  }\n}"}' \
    --compressed ;
    

    echo
    read -p "Post S5 Press enter to continue..."  junk
    echo
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllOutbreaks","variables":{},"query":"query findAllOutbreaks($page: Page) {\n  findAllOutbreaks(page: $page) {\n    content {\n      id {\n        codeSetNm\n        code\n        __typename\n      }\n      codeShortDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    echo
    read -p "Post S5.5 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllEthnicityValues","variables":{},"query":"query findAllEthnicityValues($page: Page) {\n  findAllEthnicityValues(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    
    echo
    read -p "Post S6 Press enter to continue..."  junk
    echo
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllPatientIdentificationTypes","variables":{},"query":"query findAllPatientIdentificationTypes($page: Page) {\n  findAllPatientIdentificationTypes(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
        --compressed ;



    echo
    read -p "Post S7 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllRaceValues","variables":{},"query":"query findAllRaceValues($page: Page) {\n  findAllRaceValues(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    
    
    echo
    read -p "Post S8 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllUsers","variables":{},"query":"query findAllUsers($page: Page) {\n  findAllUsers(page: $page) {\n    content {\n      nedssEntryId\n      userId\n      userFirstNm\n      userLastNm\n      recordStatusCd\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;

    echo
    read -p "Post S9 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"states","variables":{},"query":"query states {\n  states {\n    value\n    name\n    abbreviation\n    __typename\n  }\n}"}' \
    --compressed ;
    


    echo
    read -p "Post S10 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/encryption/decrypt" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: application/json' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: text/plain' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw 'NrtpfI68PmAX2uhPtGP+AEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi' \
    --compressed ;
    
    
    
    echo
    read -p "Post S11 Press enter to continue..."  junk
    echo
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output /dev/null \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw $'{"operationName":"findPatientsByFilter","variables":{"filter":{"recordStatus":["ACTIVE"],"gender":"F"},"page":{"pageNumber":0,"pageSize":25,"sortField":"relevance"}},"query":"query findPatientsByFilter($filter: PersonFilter\u0021, $page: SortablePage) {\\n  findPatientsByFilter(filter: $filter, page: $page) {\\n    content {\\n      patient\\n      birthday\\n      age\\n      gender\\n      status\\n      shortId\\n      legalName {\\n        first\\n        middle\\n        last\\n        suffix\\n        __typename\\n      }\\n      names {\\n        first\\n        middle\\n        last\\n        suffix\\n        __typename\\n      }\\n      identification {\\n        type\\n        value\\n        __typename\\n      }\\n      addresses {\\n        use\\n        address\\n        address2\\n        city\\n        state\\n        zipcode\\n        __typename\\n      }\\n      phones\\n      emails\\n      __typename\\n    }\\n    total\\n    __typename\\n  }\\n}"}' \
    --compressed ;

    # I think this final post gets the results with total count 
    echo
    read -p "Post S12 Press enter to continue..."  junk
    echo
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    --output ${SEARCH_RESULTS} \
    -H "authority: ${TMP_HOST}" \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H "origin: ${BASE_URL}" \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw $'{"operationName":"findPatientsByFilter","variables":{"filter":{"recordStatus":["ACTIVE"],"gender":"F"},"page":{"pageNumber":0,"pageSize":25,"sortField":"relevance"}},"query":"query findPatientsByFilter($filter: PersonFilter\u0021, $page: SortablePage) {\\n  findPatientsByFilter(filter: $filter, page: $page) {\\n    content {\\n      patient\\n      birthday\\n      age\\n      gender\\n      status\\n      shortId\\n      legalName {\\n        first\\n        middle\\n        last\\n        suffix\\n        __typename\\n      }\\n      names {\\n        first\\n        middle\\n        last\\n        suffix\\n        __typename\\n      }\\n      identification {\\n        type\\n        value\\n        __typename\\n      }\\n      addresses {\\n        use\\n        address\\n        address2\\n        city\\n        state\\n        zipcode\\n        __typename\\n      }\\n      phones\\n      emails\\n      __typename\\n    }\\n    total\\n    __typename\\n  }\\n}"}' \
    --compressed ;

}
####################################################################################################

# BEGIN actual work


echo "##################################################################################################################################"
echo "logging in and fetching cookies"
login_nbs ${BASE_URL} ${LOGIN_USER} ${TMP_PASS}
RETURN_CODE=$?
if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi

#echo TMP_TOKEN=${TMP_TOKEN}
echo 
            
if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
goto_advanced_search ${BASE_URL} ${TMP_TOKEN};
if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi

echo "#################################################################"
echo "now searching for Female patients"
if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi

patient_search ${BASE_URL} ${TMP_TOKEN}; 
SEARCH_COUNT=`cat ${SEARCH_RESULTS} | jq .data.findPatientsByFilter.total `
echo
echo "NOTICE: SEARCH_COUNT=${SEARCH_COUNT}"
echo 

if [ "${SEARCH_COUNT}" -ne "0" ]
then
    echo "NOTICE: ${SEARCH_COUNT} patients found, good!"
    #echo "NOTICE: SEARCH_COUNT=${SEARCH_COUNT}"
else
    echo "ERROR:  searching for Patients"
    exit 2
fi

echo
            
            
echo "#################################################################"


echo 
read -p "deleting cookies and search results, Press enter to continue..."  junk
rm ${COOKIE_JAR} ${SEARCH_RESULTS}

