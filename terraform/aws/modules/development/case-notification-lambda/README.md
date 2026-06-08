## Creating lambda layer for pyodbc and paramiko
### Requirements
- Linux environment or Docker environment such as Docker Desktop
- Ability to download remote packages/images from microsoft and public.ecr.aws/lambda/python

### Steps
Run the following steps
1. Within your command line starting at the case-notification-lambda directory
    ```
    cd ./docker
    docker build -t lambda-layer-msodbcsql18 .
    ```
 
2. Copy from container to the layers directory within case-notification-lambda module for deployment
    - cd ../ 
    - docker run --rm -v ${PWD}:/out --entrypoint cp lambda-layer-msodbcsql18 /layer.zip /out/layers/case-notification-lambda.zip        
    ```
    docker cp <container_name_or_id>:/tmp/case-notification-layer.zip <path_on_local_machine_to_module>/layers
    ```
    **NOTE: folder structure when uploading to lambda layers**
    ```    
        /opt/python/      # Python packages    
        /opt/lib/         # unix libraries
        /opt/etc          # ODBC connection files odbcinst.ini and odbc.ini

## Running Terraform
TODO