# NEDSS-Infrastructure Terraform

## Tools

### terraform-docs

terraform-docs is used to generate consistent documentation about a Terraform module, including requirements, providers, modules, resources/data sources, inputs and outputs. A configuration file is included in the root of this repository (.terraform-docs.yml). To generate an update to the documentation, run the following commands:

```
cd <path to module>
terraform-docs markdown -c <path to config file> --output-file ./README.md .
```

This will generate a new file in a directory if the README.md does not exist. If the file does exist, the command will update the content in between the `<!-- BEGIN_TF_DOCS -->/<!-- END_TF_DOCS -->` comments. Any content outside the comment tags will be left as-is.
