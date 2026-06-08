


# Set Environment Variables
#db_trace_on="No" 
#update_database="false" 
SAS_BASE_PATH="/opt" 
SAS_HOME="/opt/sas9.4/install/SASHome/SASFoundation/9.4"
WILDFLY_HOME="/opt"
#PHCMartETL_cron_schedule="0 0 * * *"
#MasterEtl_cron_schedule="0 0 * * *"
#sas_user_pass=""
#TCPPORTFIRST="52000"
#TCPPORTLAST="52005"
#ADDITIONAL_SAS_FLAGS=""
CP_CMD="echo ln -s"
#CP_CMD="ls -l"
#CP_CMD="echo cp"
#CP_CMD="echo cp -p"

${CP_CMD} ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/dw/etl/src/Health-check.sas ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/dw/etl/src/HEALTH-CHECK.sas
${CP_CMD} ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/pgm/PA04_Std.sas ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/pgm/PA04_STD.SAS


cd ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/pgm/
for FILE in *;do upperFile=$(echo $FILE | awk -F'.' '{print $1"."toupper($2)}'); ${CP_CMD} $FILE $upperFile; done

cd ${WILDFLY_HOME}/wildfly-10.0.0.Final/nedssdomain/Nedss/report/template/
for FILE in *;do lowerFile=$(echo $FILE | awk -F'.' '{print tolower($1)"."$2}'); ${CP_CMD} $FILE $lowerFile; done

cd /home/SAS
echo chmod -R 755 ${WILDFLY_HOME}/wildfly-10.0.0.Final
echo chown -R SAS:SASgroup ${WILDFLY_HOME}/wildfly-10.0.0.Final

