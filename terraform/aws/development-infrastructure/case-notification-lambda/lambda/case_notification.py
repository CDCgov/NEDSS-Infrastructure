import boto3
from botocore.config import Config
import pyodbc #NEEDS LAMBDA LAYER for library and ODBC driver
import os
import logging
import json
import math
import xml.etree.ElementTree as ET
import paramiko #NEEDS LAMBDA LAYER for library

# Lambda Global Environment Variables (all env variables are strings)
dry_run = os.environ['DRY_RUN'].lower()
max_batch_size = int(os.environ["MAX_BATCH_SIZE"]) # max integer number of reports to pull at once
reported_service_types = os.environ['REPORTED_SERVICE_TYPES'] # example, requires parenthesis, "('NNDM_1.1.3', 'NND_Case_Note', 'NBS_1.1.3_LDF', 'MVPS')"
sftp_secret_name = os.environ["SECRET_MANAGER_SFTP_SECRET"]
sftp_put_filepath = os.environ["SFTP_PUT_FILEPATH"] # no trailing '/'
db_secret_name = os.environ["SECRET_MANAGER_DB_SECRET"]

# Global Variables
custom_database_header = "charPayloadContent"
os.environ["ODBCSYSINI"] = "/opt/etc" # required environment variable updates to pick up ODBC driver in lambda layer
os.environ["ODBCINI"] = "/opt/etc/odbc.ini" # required environment variable updates to pick up ODBC driver in lambda layer
os.environ["LD_LIBRARY_PATH"] = "/opt/lib:" + os.environ.get("LD_LIBRARY_PATH", "") # required environment variable updates to pick up ODBC driver in lambda layer


# --- Logging Setup ---
logger = logging.getLogger()
logger.setLevel(logging.INFO) # currently only sets as info, need to update later
logging.basicConfig(level=logging.INFO)

# --- GLOBAL DEBUG MODE VARIABLE ---
# GLOBAL_DEBUG_MODE = int(os.environ.get('DEBUG_MODE', '0')) # Default to 0 (off).

# --- AWS Boto3 Clients ---
rds_config = Config(connect_timeout=10, read_timeout=60)
secrets_config = Config(connect_timeout=10, read_timeout=60)
rds_client = boto3.client('rds', config=rds_config)
secrets_client = boto3.client("secretsmanager", config=secrets_config)

# Create a connection to sql server
def _create_sql_connection(db_secret_dict):

    # Get database variables
    db_server_name = db_secret_dict["server_name"]
    db_user_name = db_secret_dict["username"]
    db_user_pass = db_secret_dict["password"]

    # get server endpoint and port
    response = rds_client.describe_db_instances(DBInstanceIdentifier=db_server_name)
    db_server_endpoint = response["DBInstances"][0]["Endpoint"]["Address"]
    db_server_port = response["DBInstances"][0]["Endpoint"]["Port"]
     
    database = "NBS_MSGOUTE" # always same DB for nnds
    logger.info(f"Connecting to Database: {db_server_name}")
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={db_server_endpoint},{db_server_port};"
        f"DATABASE={database};"
        f"UID={db_user_name};"
        f"PWD={db_user_pass};"
        "Encrypt=yes;TrustServerCertificate=yes;"
    )
    return conn

# Get count of items to transmit from TransportQ_out
def _get_msg_count_transportq_out(db_secret_dict,reported_service_types):
    count = 0
    conn = _create_sql_connection(db_secret_dict=db_secret_dict)
    try:
        with conn.cursor() as cursor: 
            
            cursor = conn.cursor()
            sql_query = """
                    SELECT COUNT(*) 
                        FROM TransportQ_out 
                        WHERE processingStatus='queued' AND action='send' AND messageId<>'' AND service IN {};                    
                """.format(reported_service_types)
            cursor.execute(sql_query)
            count = cursor.fetchone()[0]            
    except Exception as e:
        logger.error(f"An error occurred getting counts from TransportQ_out: {e}")
    finally:
        conn.close()

    return count

def _get_msg_payload_transportq_out(db_secret_dict, max_batch_size, reported_service_types):
    transportq_out_rows_to_process = []
    conn = _create_sql_connection(db_secret_dict=db_secret_dict)
    try:        
        with conn.cursor() as cursor: 
            sql_query = """
                SELECT TOP ({}) cast(cast(payloadContent as varbinary(max)) as varchar(max)) AS {}, * 
                    FROM TransportQ_out 
                    WHERE processingStatus='queued' AND action='send' AND messageId<>'' AND service IN {}
                    ORDER BY priority asc, messageCreationTime asc;
            """.format(max_batch_size,custom_database_header,reported_service_types)
            
            cursor.execute(sql_query)
            transportq_out_rows_to_process = cursor.fetchall()        
    except Exception as e:
        logger.error(f"An error occurred getting payload from TransportQ_out: {e}")
    finally:
        conn.close()
    return transportq_out_rows_to_process

def _send_msg_payload_transportq_out(db_secret_dict, transportq_out_row_to_process, sftp_put_filepath, sftp_hostname, sftp_username, sftp_password, dry_run="false"):
    success_status = False    
    conn = _create_sql_connection(db_secret_dict=db_secret_dict)
    try:
        filename = None
        # transform file to xml and print as xml if type 
        if transportq_out_row_to_process.service == "NNDM_1.1.3":
            # Create xml files to send            
            try:        
                root = ET.fromstring(getattr(transportq_out_row_to_process, custom_database_header))        
                tree = ET.ElementTree(root)
                _strip_ns(root)
                _indent_xml(root)
                tree.write(f"/tmp/{transportq_out_row_to_process.destinationFilename}.xml", encoding="utf-8", xml_declaration=False)
                filename = f"{transportq_out_row_to_process.destinationFilename}.xml"   
            except ET.ParseError as e:
                print("Invalid XML:", e)           
        else:
            # Create hl7 files to send
            with open(f"/tmp/{transportq_out_row_to_process.destinationFilename}.hl7", 'w') as file_object:
                print(getattr(transportq_out_row_to_process, custom_database_header), file=file_object)
            filename = f"{transportq_out_row_to_process.destinationFilename}.hl7"

        # Connect to SFTP and send file
        success_status = _write_to_sftp(
            file=filename, 
            sftp_put_filepath=sftp_put_filepath, 
            sftp_hostname=sftp_hostname, 
            sftp_username=sftp_username, 
            sftp_password=sftp_password, 
            dry_run=dry_run
        )

        # Update Database with send status
        db_success_status = False
        if success_status:
            with conn.cursor() as cursor:            
                logger.info("Updating Database with processingStatus=done")
                if dry_run == "false": 
                    sql_query = """
                        UPDATE TransportQ_out
                            SET processingStatus='done', messageSentTime=(SELECT CONVERT(varchar(19), GETDATE(), 126) AS [ISO8601DateTime])
                            WHERE destinationFilename='{}'                    
                    """.format(transportq_out_row_to_process.destinationFilename)               
                    cursor.execute(sql_query)
                else:
                    logger.info("Dry run enabled, database not updated! Continuing as if update occured...")
                db_success_status = True        

        if db_success_status and success_status:            
            logger.info(f"Successfully sent notification for message with messageId {transportq_out_row_to_process.messageId} and destinationFilename {transportq_out_row_to_process.destinationFilename}")
        elif success_status and db_success_status == False:
            logger.info(f"Unable to update database TransportQ_out with processingStatus='done'. Successfully sent notification for message with messageId {transportq_out_row_to_process.messageId} and destinationFilename {transportq_out_row_to_process.destinationFilename}")
   
        if filename is None:
            raise Exception(f"Unable to create file for messageId {transportq_out_row_to_process.messageId} and destinationFilename {transportq_out_row_to_process.destinationFilename}")
        
    except Exception as e:
        logger.error(f"An error occurred getting processing message from TransportQ_out: {e}")
    finally:
        conn.close()
    return success_status    

def _strip_ns(elem):
    # Remove namespace from tag
    elem.tag = elem.tag.split('}', 1)[-1]
    for child in elem:
        _strip_ns(child)

def _indent_xml(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        for child in elem:
            _indent_xml(child, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def _write_to_sftp(file, sftp_put_filepath, sftp_hostname, sftp_username, sftp_password, dry_run="false"):
    # Function
    # Take a local file and send it to client via sftp endpoint and credentials
    # Variables
    # file =  filename (always on /tmp path for lambda)
    # dry_run = True/False

    success_status = False 
    # File paths    
    remote_file_path = f"{sftp_put_filepath}/{file}"
    local_file_path = f"/tmp/{file}"  # Lambda allows writes only to /tmp    
    
    # Connect with username + password
    transport = paramiko.Transport((sftp_hostname, 22))
    transport.connect(username=sftp_username, password=sftp_password)
    try:
        with paramiko.SFTPClient.from_transport(transport) as sftp:  
            if dry_run == "false":  
                sftp.put(local_file_path, remote_file_path)
                sftp.stat(remote_file_path)
                logger.info(f"Uploaded {local_file_path} → {remote_file_path}")
            else:
                logger.info(f"Dry run enabled, files {local_file_path} → {remote_file_path} not sent!")            
        success_status = True
    except Exception as e:
        logger.error(f"Unable to upload {local_file_path} → {remote_file_path}: {e}")
    finally:
        transport.close()    

    return success_status

def _get_secret(secret_name):     

    # Get secret value
    response = secrets_client.get_secret_value(SecretId=secret_name)

    # The secret is stored as a string; parse JSON
    secret_string = response["SecretString"]
    secret_dict = json.loads(secret_string)

    return secret_dict

# Check remaining lambda time and reinvoke lambda if less than 30 seconds remaining
# This must be called for every send to prevent situations where a message is sent but commit to DB does not occur
def _restart_lambda_check(context, total_time):
    restart_lambda = False
    milliseconds_threshold = 30000
    remaining_time = context.get_remaining_time_in_millis()
    # less than 30 seconds left
    if remaining_time < milliseconds_threshold and total_time > milliseconds_threshold:
        restart_lambda = True
    return restart_lambda

def _reinvoke_lambda(context,total_time):
        read_timeout = total_time - 20000 #total time - 20 sec (20000ms)
        lambda_config = Config(connect_timeout=10, read_timeout=read_timeout) # needs to be slightly less than the 5 minute timeout
        lambda_client = boto3.client("lambda", config=lambda_config)

        lambda_client.invoke(
            FunctionName=context.function_name,
            InvocationType="Event",  # async
            Payload=json.dumps({})
        )

def lambda_handler(event, context):
    
    # Lambda Environment Variables
    total_time = context.get_remaining_time_in_millis()

    # Get database credentials
    db_secret_dict = _get_secret(db_secret_name)    
    
    # Get sftp credentials
    sftp_secret_dict = _get_secret(sftp_secret_name)
    sftp_hostname = sftp_secret_dict["sftp_hostname"]
    sftp_username = sftp_secret_dict["sftp_username"]
    sftp_password = sftp_secret_dict["sftp_password"]

    total_messages = _get_msg_count_transportq_out(db_secret_dict=db_secret_dict,reported_service_types=reported_service_types)    
    total_batches = math.ceil(total_messages/max_batch_size)
 
    # Process in batches to reduce the chance of timeout. Small batches = less of a chance of timeout but more queries run against db
    messages_sent = 0 
    for i in range(total_batches):
        logger.info(f"Processing batch {i+1}/{total_batches}. Max Batch Size = {max_batch_size}")
        transportq_out_rows_to_process = _get_msg_payload_transportq_out(db_secret_dict=db_secret_dict, max_batch_size=max_batch_size, reported_service_types=reported_service_types)
        return_report_number = len(transportq_out_rows_to_process)               
        for j in range(return_report_number):
            success_status = _send_msg_payload_transportq_out(
                db_secret_dict=db_secret_dict, 
                transportq_out_row_to_process=transportq_out_rows_to_process[j],
                sftp_put_filepath = sftp_put_filepath, 
                sftp_hostname=sftp_hostname, 
                sftp_username=sftp_username, 
                sftp_password=sftp_password, 
                dry_run=dry_run
                )
            if success_status:
                messages_sent+=1

        # after each batch check if there is enough time to proceed to next batch, if not reinvoke lambda until finished. Assuming at most 30 seconds required for a single batch.
        # reduce MAX_BATCH_SIZE environment variable if taking longer than 30 seconds for each batch
        restart_lambda = _restart_lambda_check(context=context, total_time=total_time)
        # if we have to restart lambda check and exit lambda
        if restart_lambda:
            _reinvoke_lambda(context, total_time=total_time)
            logger.info(f"Lambda timeout imminent, restarting Lambda! Sucessfully Sent {messages_sent} message(s)!")
            return

    if messages_sent == 0:
        logger.info("No messages found to send!")
    else:
        logger.info(f"Sucessfully Sent {messages_sent} message(s)!")
