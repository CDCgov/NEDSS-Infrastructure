import shutil
import pprint
import json
import os
import argparse
import sys
import subprocess
import sys
from pathlib import Path

def migrate_terraform_state(layers_directory, unique_resources_found):
    """
    Migrates terraform resources found in source.tfstate

    Returns: 
    resources_migrated: Dictionary of migrated resources and destination
    resources_remaining: List of resource unable to be migrated
    """

    resources_migrated = {}

    if not Path(layers_directory).exists():
        print(f"Error: Layered Terraform directory  {layers_directory} does not exist!")
        sys.exit(1)
    
    dir_obj = Path(layers_directory)
   
    print(f"--- Migrating terraform state for layer {dir_obj.name} ---")
           
    # Using 'with' ensures the file is closed even if an error occurs
    try:
        # glob("*.tf") handles the iteration for us
        for tf_file in dir_obj.glob("*.tf"):
            for resource in unique_resources_found:
                with open(tf_file, 'r') as open_file:                
                    split_resource = resource.split(".")                    
                    file_content = open_file.read()
                    
                    # find module and migrate state
                    if f"{split_resource[0]} \"{split_resource[1]}\"" in file_content:
                        
                        try:
                            # 'check=True' makes Python raise an error if Terraform fails
                            # 'capture_output=True' grabs the text so you can process it

                            cmd = f"terraform state mv -state=\"source.tfstate\" -state-out=\"{dir_obj.name}.tfstate\" \"{resource}\" \"{resource}\""                                                           
                            subprocess.run(
                                cmd,                
                                check=True,
                                shell=True,
                                capture_output=True,
                                text=True
                            )

                            print(f"✅ Migrated '{resource}' to file {dir_obj.name}.tfstate")
                            resources_migrated[resource] =  f"{dir_obj.name}.tfstate"
                            
                            
                            break                            
                            
                        except subprocess.CalledProcessError as e:        
                            print(f"!!! EXIT CODE: {e.returncode}")
                            print(f"!!! ERROR MESSAGE (STDERR):\n{e.stderr}")
                            # Sometimes Terraform puts the error in stdout depending on the version
                            print(f"!!! OUTPUT (STDOUT):\n{e.stdout}")
                            sys.exit(e.returncode)
                        except Exception as e:
                            print(f"Error:\n{e}")
                            sys.exit(e.returncode)
    except Exception as e:
        print(f"❌ Error processing files: {e}")
        return False

    # Check resources, not migrated
    resources_remaining = []
    keys_list = list(resources_migrated)
    for resource in unique_resources_found:
        if resource not in keys_list:
            resources_remaining.append(resource) 
        
    print("Remaining resources",resources_remaining)

    return resources_migrated, resources_remaining

def get_unique_modules():    
    unique_resources_found = []

    print(f"--- Checking terraform state for modules ---")
    
    try:
        # 'check=True' makes Python raise an error if Terraform fails
        # 'capture_output=True' grabs the text so you can process it
        
        result = subprocess.run(
            "terraform state list -state=source.tfstate",                
            check=True,
            shell=True,
            capture_output=True,
            text=True
        )
       
        resources_found = result.stdout.splitlines()
    except subprocess.CalledProcessError as e:        
        print(f"!!! EXIT CODE: {e.returncode}")
        print(f"!!! ERROR MESSAGE (STDERR):\n{e.stderr}")
        # Sometimes Terraform puts the error in stdout depending on the version
        print(f"!!! OUTPUT (STDOUT):\n{e.stdout}")
        sys.exit(e.returncode)
    except Exception as e:
        print(f"Error:\n{e}")
        sys.exit(e.returncode)
    
    # Parse and find unique modules
    unique_modules = set()
    for resource in resources_found:
        if resource.startswith("module."):
            # Split by dots: ['module', 'vpc', 'aws_vpc', 'main']
            parts = resource.split(".")
            # We want "module.vpc", which are the first two parts
            module_name = f"{parts[0]}.{parts[1]}"
            unique_modules.add(module_name)
    
    # 4. Convert set back to a sorted list
    unique_resources_found = sorted(list(unique_modules))

    print(f"Success gathering state resources --")  
    print(unique_resources_found, "\n---")      
   
    return unique_resources_found

def split_terraform_state(target_dir_path, working_dir):
    """
    Pulls terraform state from a specific directory.
    target_dir_path: A pathlib.Path object
    
    Returns success (bool)
    """

    # Dynamically find terraform in the PATH
    terraform_path = shutil.which("terraform")
    current_env = os.environ.copy()
    
    if not terraform_path:
        print("Error: 'terraform' binary not found in system PATH.")
        return False
    else:
        print("Found terraform on path:", terraform_path)

    # Convert Path object to string for subprocess
    dir_str = Path(target_dir_path).resolve()

    print(f"--- Pulling terraform state in", dir_str,"---\n")

    if Path(f"{dir_str}/source.tfstate").exists():
        print("Error: source.tfstate already EXISTS! If you wish to pull a fresh copy please rename the existing source.tfstate.")
        sys.exit(1)
    
    commands = [
        "terraform init -input=false",
        "terraform state pull > source.tfstate",
        f"mv source.tfstate {working_dir}"              
    ]

    env = os.environ.copy()
    env["TF_LOG"] = "INFO" # For better logging
    success = False
    
    for cmd in commands:       
        try:
            # 'check=True' makes Python raise an error if Terraform fails
            # 'capture_output=True' grabs the text so you can process it
            
            result = subprocess.run(
                f"{cmd}",                
                cwd=dir_str,
                env=current_env,
                check=True,
                shell=True,
                capture_output=True,
                text=True
            )
            print(f"Success running command --", cmd)
            
            # Success only True if all previous commands were successful
            if cmd == commands[-1]:
                success = True

        except subprocess.CalledProcessError as e:
            print(f"!!! COMMAND FAILED: {e.cmd}")
            print(f"!!! EXIT CODE: {e.returncode}")
            print(f"!!! ERROR MESSAGE (STDERR):\n{e.stderr}")
            # Sometimes Terraform puts the error in stdout depending on the version
            print(f"!!! OUTPUT (STDOUT):\n{e.stdout}")
            sys.exit(e.returncode)
        except Exception as e:
            print(f"Error:\n{e}")
            sys.exit(e.returncode)
        
            
    return success

def main():

    # Set variables (overrides?)
    layers = ["0-landing-zone", "1-nbs6", "2-nbs7", "3-applications"]

    # 1. Setup Argument Parser
    parser = argparse.ArgumentParser(
        description="Split terraform state (non-destructive) python script."
    )

    # 2. Define arguments with Environment Variables as defaults
    # This allows: CLI Flag > Environment Variable > Hardcoded Default
    parser.add_argument(
        "--source",
        dest="source",
        default=os.environ.get("TERRAFORM_SOURCE",Path().resolve()),
        help="Relative or absolute path to directory containing deployed NBS Terraform. Default = this script directory."
    )

    parser.add_argument(
        "--target",
        dest="target",
        default=os.environ.get("TERRAFORM_TARGET",Path().resolve()),
        help="Relative or absolute path to directory containing target layered NBS Terraform. Default = this script directory."
    )

    parser.add_argument(
        "--pull-fresh",
        dest="pull_fresh",
        default="yes",
        type=lambda x: x.lower(), # Automatically converts input to lowercase
        choices=["yes", "no"],
        help="Pull a fresh copy of the terraform state (yes/no)? If no, file must be in same directory as this script and be named source.tfstate."
    )
  
    args = parser.parse_args()

    # Convert to a Path object and resolve to Absolute Path
    # .resolve() handles '..' and '.' and turns relative into absolute
    # Works natively on Windows (C:\...) and Linux (/home/...)
    path_obj_source = Path(args.source).resolve()
    path_obj_target = Path(args.target).resolve()
    
    # Validation source input
    if not path_obj_source.exists() and args.pull_fresh == "yes":
        print(f"Error: The source path '{path_obj_source}' does not exist.")
        sys.exit(1)

    if not path_obj_source.is_dir() and args.pull_fresh == "yes":
        print(f"Error: The source path '{path_obj_source}' is a file, not a directory.")
        sys.exit(1)

    # Validation source input
    if not path_obj_target.exists() and args.pull_fresh == "yes":
        print(f"Error: The target path '{path_obj_target}' does not exist.")
        sys.exit(1)

    if not path_obj_target.is_dir() and args.pull_fresh == "yes":
        print(f"Error: The target path '{path_obj_target}' is a file, not a directory.")
        sys.exit(1)
    
    if args.pull_fresh == "no" and not Path("./source.tfstate").exists():
        print("Error: source.tfstate not found. File must be in same directory as this script and be named source.tfstate.")
        sys.exit(1)

    working_dir = Path(".").resolve()    
    print("\n--- Working directory (files generated here):", working_dir, "---\n")    

    # 4. Pathing Example
    # Works natively on Windows (C:\...) and Linux (/home/...)
    base_path = os.getcwd()
    log_file = os.path.join(base_path, "logs", "app.log")

    # Migrate terraform state
    split_success = False
    resource_migrated = {}
    resources_remaining = []
    if args.pull_fresh == 'yes':
        split_success = split_terraform_state(path_obj_source, working_dir)

    if split_success or args.pull_fresh == 'no':
        unique_resources_found = get_unique_modules()

        for layer in layers:
            resource_migrated_temp, resources_remaining_temp = migrate_terraform_state(f"{args.target}/{layer}", unique_resources_found)
            resource_migrated = resource_migrated | resource_migrated_temp
            unique_resources_found = resources_remaining_temp
            resources_remaining = unique_resources_found
   
    print("\n--- Execution Summary ---")
    print("Resources Migrated with format {'<resource>:' '<destination>'} ")    
    pprint.pprint(resource_migrated, compact=True, sort_dicts=True)

    print("\nResources NOT Migrated")    
    pprint.pprint(resources_remaining, compact=True, sort_dicts=True)
    # for migrated in resource_migrated:
    #     print("  ",migrated,"   ", resource_migrated[migrated])
    print(f"--------------------------")
    print(f"Terraform Source Directory:    {args.source}")
    print(f"Layered Terraform Target Directory:     {args.target}")    
    print(f"--------------------------")

if __name__ == "__main__":
    main()
