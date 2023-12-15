#!/bin/bash

##########################################################################
#
#  Description: This script logs into nbs, creates a Patient, searches a
#  Patient
#  and then deletes the Patient, 
#  TODO: we should create a readonly version
#
##########################################################################

COUNT=1
# DEBUG ON
#DEBUG=1
CURL='curl -q --silent'
COOKIE_JAR=cookie-jar.$$


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

    #curl -q -X "POST" "${TMP_URL}/login" \
    #    -H 'Content-Type: application/json' \
    #    --silent \
    #    -d $'{
    #"username": "'"${TMP_USER}"'"
    #}'

    read -p "load login page, Press enter to continue..."  junk
    # load the login page, does this set a cookie?
    ${CURL} "${TMP_URL}/nbs/login" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: no-cache' \
    -H 'cookie: JSESSIONID=Cvrw1FDWprQa3LsjZbYwJkVO2ZL7Pes6YdPJn8HU.ec2amaz-50h0je7' \
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
    echo "RETURN_CODE=$?"
    echo TMP_TOKEN=${TMP_TOKEN}
    echo 
    
    ####################################################################################################
    # start the actual login post - user and password included
    read -p "start login, Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/nbs/nbslogin" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/nbs/login' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw 'mode=&ObjectType=&OperationType=&PopupDataResult=&UserName=state&Password=badpass' \
    --compressed
    
    #  -H 'cookie: JSESSIONID=K1Lk5khAMxRttnXY1_1I0Z2xTEfXy12NZQzwGYi_.ec2amaz-50h0je7' \
    read -p "second login url Press enter to continue..."  junk
    # next get
    ${CURL} "${TMP_URL}/nbs/nfc?UserName=state" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H 'referer: https://app.fts3.nbspreview.com/nbs/login' \
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

    read -p "third login url loadhome page, Press enter to continue..."  junk
    # last document get as part of login
    ${CURL} "${TMP_URL}/nbs/HomePage.do?method=loadHomePage" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'cache-control: max-age=0' \
    -H 'referer: https://app.fts3.nbspreview.com/nbs/login' \
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

    #curl -X "POST" "${TMP_URL}/graphql" \
        #-H "Authorization: Bearer ${TMP_TOKEN}" \
        #--silent \
        #-H 'Content-Type: application/json; charset=utf-8' \
        #-d $'{
	    #"query": "mutation create($patient:PersonInput!){createPatient(patient:$patient){id shortId}}",
	    #"variables": {
		    #"patient": {
			    #"comments": "Created for Development testing",
			    #"asOf": "2023-10-06T18:14:23+00:00",
			    #"names": [
				    #{
					    #"use": "L",
					    #"first": "Aya",
					    #"last": "Brea"
				    #}
			    #]
		    #}
	    #}
    #}'
    ####################################################################################################
    # now click on advanced search
    # this gets a few cookies
    # Set-Cookie: nbs_user=state; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; Secure
    # Set-Cookie: JSESSIONID=blahblah; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; HttpOnly
    # Set-Cookie: nbs_token=blah.blah.blah; Max-Age=1800; Expires=Thu, 14 Dec 2023 21:45:31 GMT; Path=/; Secure
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/nbs/MyTaskList1.do?ContextAction=GlobalPatient" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'referer: https://app.fts3.nbspreview.com/nbs/HomePage.do?method=loadHomePage' \
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
    
    #-H 'cookie: JSESSIONID=rsFY26RDq5NMwHtf0kFjsanypXSVP_P_ANA-Ti47.ec2amaz-50h0je7' \
    
    TMP_BEARER_TOKEN=`grep nbs_token ${COOKIE_JAR} | awk '{print $7}'`
    echo TMP_BEARER_TOKEN=${TMP_BEARER_TOKEN}
    
    read -p "Post gets bearer? Press enter to continue..."  junk
    # this uses those cookies
    ${CURL} "${TMP_URL}/advanced-search" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'referer: https://app.fts3.nbspreview.com/nbs/HomePage.do?method=loadHomePage' \
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
    ## Patient Search(7.0.0)
    TMP_URL=$1
    TMP_TOKEN=$2
    #curl -X "POST" "${TMP_URL}/graphql" \
        #--silent \
        #-H "Authorization: Bearer ${TMP_TOKEN}" \
        #-H 'Content-Type: application/json; charset=utf-8' \
        #-d $'{
	    #"query": "query search($filter:PersonFilter!,$page:SortablePage){findPatientsByFilter(filter:$filter,page:$page){content{id shortId names{firstNm middleNm lastNm}}total}}",
	    #"variables": {
		    #"filter": {
			    #"lastName": "brea",
			    #"recordStatus": [
				    #"ACTIVE"
			    #]
		    #},
		    #"page": {
			    #"pageNumber": 0,
			    #"pageSize": 25,
			    #"sortDirection": "ASC",
			    #"sortField": "lastNm"
		    #}
	    #}
    #}'

    read -p "Post needs Bearer Press enter to continue..."  junk

    ${CURL} "${TMP_URL}/encryption/encrypt" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: application/json' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"recordStatus":["ACTIVE"],"gender":"F"}' \
    --compressed
    
    TMP_BEARER_TOKEN=`grep nbs_token ${COOKIE_JAR} | awk '{print $7}'`
    echo TMP_BEARER_TOKEN=${TMP_BEARER_TOKEN}
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllProgramAreas","variables":{},"query":"query findAllProgramAreas($page: Page) {\n  findAllProgramAreas(page: $page) {\n    id\n    progAreaDescTxt\n    nbsUid\n    statusCd\n    statusTime\n    codeSetNm\n    codeSeq\n    __typename\n  }\n}"}' \
    --compressed ;
    
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllConditionCodes","variables":{},"query":"query findAllConditionCodes($page: Page) {\n  findAllConditionCodes(page: $page) {\n    id\n    conditionDescTxt\n    __typename\n  }\n}"}' \
    --compressed ;
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllJurisdictions","variables":{},"query":"query findAllJurisdictions($page: Page) {\n  findAllJurisdictions(page: $page) {\n    id\n    typeCd\n    assigningAuthorityCd\n    assigningAuthorityDescTxt\n    codeDescTxt\n    codeShortDescTxt\n    effectiveFromTime\n    effectiveToTime\n    indentLevelNbr\n    isModifiableInd\n    parentIsCd\n    stateDomainCd\n    statusCd\n    statusTime\n    codeSetNm\n    codeSeqNum\n    nbsUid\n    sourceConceptId\n    codeSystemCd\n    codeSystemDescTxt\n    exportInd\n    __typename\n  }\n}"}' \
    --compressed ;
    

    read -p "Post XXX Press enter to continue..."  junk
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllOutbreaks","variables":{},"query":"query findAllOutbreaks($page: Page) {\n  findAllOutbreaks(page: $page) {\n    content {\n      id {\n        codeSetNm\n        code\n        __typename\n      }\n      codeShortDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllEthnicityValues","variables":{},"query":"query findAllEthnicityValues($page: Page) {\n  findAllEthnicityValues(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    
    read -p "Post XXX Press enter to continue..."  junk
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllPatientIdentificationTypes","variables":{},"query":"query findAllPatientIdentificationTypes($page: Page) {\n  findAllPatientIdentificationTypes(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
        --compressed ;



    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllRaceValues","variables":{},"query":"query findAllRaceValues($page: Page) {\n  findAllRaceValues(page: $page) {\n    content {\n      id {\n        code\n        __typename\n      }\n      codeDescTxt\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;
    
    
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"findAllUsers","variables":{},"query":"query findAllUsers($page: Page) {\n  findAllUsers(page: $page) {\n    content {\n      nedssEntryId\n      userId\n      userFirstNm\n      userLastNm\n      recordStatusCd\n      __typename\n    }\n    total\n    __typename\n  }\n}"}' \
    --compressed ;

    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw '{"operationName":"states","variables":{},"query":"query states {\n  states {\n    value\n    name\n    abbreviation\n    __typename\n  }\n}"}' \
    --compressed ;
    


    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/encryption/decrypt" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: application/json' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: text/plain' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
    -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
    --data-raw 'NrtpfI68PmAX2uhPtGP+AEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi' \
    --compressed ;
    
    
    
    read -p "Post XXX Press enter to continue..."  junk
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
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
    read -p "Post XXX Press enter to continue..."  junk
    
    ${CURL} "${TMP_URL}/graphql" \
    --cookie ${COOKIE_JAR} \
    --cookie-jar ${COOKIE_JAR} \
    --show-error \
    -H 'authority: app.fts3.nbspreview.com' \
    -H 'accept: */*' \
    -H 'accept-language: en-US,en;q=0.9' \
    -H "authorization: Bearer ${TMP_BEARER_TOKEN}" \
    -H 'content-type: application/json' \
    -H 'origin: https://app.fts3.nbspreview.com' \
    -H 'referer: https://app.fts3.nbspreview.com/advanced-search?q=NrtpfI68PmAX2uhPtGP%2BAEpoKI2l59mCV6DbgTPxeddvSC4yjszy3d9OHe0MuddOrJBxDjHveaMe0ZseHNeSC8ffCS7GuiOi&type=search' \
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

X=$COUNT;
# repeat a command X times

echo "running process ${COUNT} times"
while [ $X -gt 0 ]
do

            echo "REMAINING PASSES $X"
            Y=$(($X-1))

            echo "##################################################################################################################################"
            echo "logging in and fetching cookies"
            #echo  login_nbs ${BASE_URL} ${LOGIN_USER} 
            #TMP_TOKEN=$(login_nbs ${BASE_URL} ${LOGIN_USER} | jq -r .token)
            login_nbs ${BASE_URL} ${LOGIN_USER} 
            RETURN_CODE=$?
            if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi

            echo "RETURN_CODE=$?"

            #echo TMP_TOKEN=${TMP_TOKEN}
            echo 
            
            #echo "#################################################################"
            #echo "now creating patient with last name Brea"
            #echo "capture ID for later use"
            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
            goto_advanced_search ${BASE_URL} ${TMP_TOKEN};
            if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi
           # 
           # TMP_PATIENT_ID=$(patient_create ${BASE_URL} ${TMP_TOKEN} |  jq -r .data.createPatient.id)
           # RETURN_CODE=$?
           # echo "Patient with last name Brea created with Patient ID = ${TMP_PATIENT_ID}"
           # echo

            echo "#################################################################"
            echo "now searching patient F"
            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi

            if patient_search ${BASE_URL} ${TMP_TOKEN} | grep "total" 
            then
                echo "NOTICE: Patients found, good!"
            else
                echo "ERROR:  searching for Patients"
            fi
            echo
            
            
            echo "#################################################################"
#            echo "now deleting patient with last name Brea and patient id ${TMP_PATIENT_ID}"
#            if [ $PROMPT ]; then echo "Hit return to continue"; read junk ; fi
#            #echo patient_delete.sh ${BASE_URL} ${TMP_TOKEN} ${TMP_PATIENT_ID}
#            patient_delete ${BASE_URL} ${TMP_TOKEN} ${TMP_PATIENT_ID} | jq
#            RETURN_CODE=$?
#            if [ $DEBUG ]; then echo "RETURN_CODE=${RETURN_CODE}"; fi
#            echo
#            echo "#################################################################"
                        

            X=$Y

done




####################################################################################################
# and now the actual search - post
# authorization Bearer


TMP_BEARER_TOKEN=`grep nbs_token ${COOKIE_JAR} | awk '{print $7}'`
echo TMP_BEARER_TOKEN=${TMP_BEARER_TOKEN}

