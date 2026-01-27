Grafana Service Account Token Rotation Lambda

This Lambda function:
1. Creates a new service account token in AWS Managed Grafana
2. Stores the new token in AWS Secrets Manager
3. Cleans up old tokens (keeps the most recent 2)

Triggered by: EventBridge scheduled rule (every 25 days by default)
"""

import boto3
import json
import os
import logging
from datetime import datetime, timezone

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients outside handler (best practice - reused across invocations)
grafana_client = boto3.client('grafana')
secrets_client = boto3.client('secretsmanager')


def handler(event, context):
    """
    Lambda handler for rotating Grafana service account tokens.
    """
    
    # Get environment variables
    workspace_id = os.environ['GRAFANA_WORKSPACE_ID']
    service_account_id = os.environ['SERVICE_ACCOUNT_ID']
    secret_name = os.environ['SECRET_NAME']
    token_expiration_days = int(os.environ['TOKEN_EXPIRATION_DAYS'])
    resource_prefix = os.environ['RESOURCE_PREFIX']
    
    # Calculate token expiration in seconds
    token_expiration_seconds = token_expiration_days * 24 * 60 * 60
    
    try:
        # Generate a unique token name with timestamp
        timestamp = datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')
        token_name = f"{resource_prefix}-token-{timestamp}"
        
        logger.info(f"Creating new Grafana service account token: {token_name}")
        logger.info(f"Workspace ID: {workspace_id}")
        logger.info(f"Service Account ID: {service_account_id}")
        logger.info(f"Token expiration: {token_expiration_days} days ({token_expiration_seconds} seconds)")
        
        # Step 1: Create new service account token
        create_response = grafana_client.create_workspace_service_account_token(
            workspaceId=workspace_id,
            serviceAccountId=service_account_id,
            name=token_name,
            secondsToLive=token_expiration_seconds
        )
        
        new_token = create_response['serviceAccountToken']['key']
        token_id = create_response['serviceAccountToken']['id']
        
        logger.info(f"Successfully created new token with ID: {token_id}")
        
        # Step 2: Store new token in Secrets Manager
        secret_value = json.dumps({
            'token': new_token,
            'token_id': token_id,
            'token_name': token_name,
            'created_at': datetime.now(timezone.utc).isoformat(),
            'expires_in_days': token_expiration_days,
            'workspace_id': workspace_id,
            'service_account_id': service_account_id
        })
        
        secrets_client.put_secret_value(
            SecretId=secret_name,
            SecretString=secret_value
        )
        
        logger.info(f"Successfully stored new token in Secrets Manager: {secret_name}")
        
        # Step 3: Clean up old tokens (optional - keep last 2)
        cleanup_old_tokens(
            grafana_client, 
            workspace_id, 
            service_account_id, 
            keep_count=2
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Token rotation successful',
                'token_name': token_name,
                'token_id': token_id,
                'expires_in_days': token_expiration_days
            })
        }
        
    except grafana_client.exceptions.ValidationException as e:
        logger.error(f"Grafana validation error: {str(e)}")
        raise e
    except grafana_client.exceptions.AccessDeniedException as e:
        logger.error(f"Grafana access denied: {str(e)}")
        logger.error("Check IAM permissions for grafana:CreateWorkspaceServiceAccountToken")
        raise e
    except secrets_client.exceptions.ResourceNotFoundException as e:
        logger.error(f"Secret not found: {str(e)}")
        raise e
    except Exception as e:
        logger.error(f"Error rotating Grafana token: {str(e)}")
        raise e


def cleanup_old_tokens(grafana_client, workspace_id, service_account_id, keep_count=2):
    """
    Remove old service account tokens, keeping the most recent ones.
    
    Args:
        grafana_client: Boto3 Grafana client
        workspace_id: Grafana workspace ID
        service_account_id: Service account ID
        keep_count: Number of recent tokens to keep
    """
    try:
        logger.info(f"Checking for old tokens to clean up (keeping {keep_count} most recent)")
        
        # List all tokens for the service account
        response = grafana_client.list_workspace_service_account_tokens(
            workspaceId=workspace_id,
            serviceAccountId=service_account_id
        )
        
        tokens = response.get('serviceAccountTokens', [])
        
        logger.info(f"Found {len(tokens)} existing tokens")
        
        if len(tokens) <= keep_count:
            logger.info(f"Only {len(tokens)} tokens exist, no cleanup needed")
            return
        
        # Sort by creation time (newest first)
        sorted_tokens = sorted(
            tokens, 
            key=lambda x: x.get('createdAt', ''), 
            reverse=True
        )
        
        # Delete older tokens (keep the newest 'keep_count')
        tokens_to_delete = sorted_tokens[keep_count:]
        
        logger.info(f"Will delete {len(tokens_to_delete)} old tokens")
        
        for token in tokens_to_delete:
            token_id = token['id']
            token_name = token.get('name', 'unknown')
            
            logger.info(f"Deleting old token: {token_name} (ID: {token_id})")
            
            try:
                grafana_client.delete_workspace_service_account_token(
                    workspaceId=workspace_id,
                    serviceAccountId=service_account_id,
                    tokenId=token_id
                )
                logger.info(f"Successfully deleted token: {token_id}")
            except Exception as delete_error:
                logger.warning(f"Failed to delete token {token_id}: {str(delete_error)}")
                # Continue with other deletions even if one fails
        
        logger.info(f"Cleanup complete. Deleted {len(tokens_to_delete)} old tokens")
        
    except Exception as e:
        logger.warning(f"Error during token cleanup: {str(e)}")
        # Don't raise - cleanup failure shouldn't fail the rotation