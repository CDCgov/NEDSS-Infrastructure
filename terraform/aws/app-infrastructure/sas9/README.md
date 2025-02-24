This module will deploy an EC2 from a preconfigured AMI with SAS installed

There are some required scripts and files that need to be on the AMI
for use in addition to the core SAS install

This starts the service:
- /etc/systemd/system/sas_spawner.service  - systemd service script - spawns process as SAS user

The following files start as templates and have values searched and replaced as part of provisioning:
- /etc/systemd/system/sas_spawner.env  - environment variables read in by service script
- /home/SAS/.odbc.ini  - odbc setup for SAS user
- /etc/odbc.ini - system ODBC setup
- /home/SAS/.bashrc  - SAS user environment variables - PATH etc.
- /home/SAS/update_config.sql - SQL to update the NBS6 DB to point to the new server


The values replaced in the template are derived from the parameter store,
local IP address and AWS cli logic

TODO: 
- change ec2 module
- fetch license file from parameter store, secrets manager or local s3?
  don't recall size constraints
- use resource prefix in deployment file and pass that as variable for
  resource names
- possibly add the template files to this module
- since the user data script can be used on the system for refresh later
  AND custom files are already required on the AMI possibly we make all
that is in user data live on the AMI and just call it from user data
- add more error checking to script 
