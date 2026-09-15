# HarborIntegrationService
.NET microservice that extends the functionality of the Harbor platform, allowing for human-readable SBOM artifact generation and additional evidence-gathering functionality. This specific version has been coded to work with the NBS project, but it is designed to be customizable/extendable by modifying the files in the `Enum` folder.

## How It Works
HarborIntegrationService leverages a Robot account set up in the Harbor UI to fetch artifact accessories (SBOMs, license information, vulnerabilities, etc.) that are associated with images that Harbor hosts. These artifacts are then processed by the service in various ways (generating human-readable SBOMs for release, aggregating license information for ATO efforts, etc.). This is accomplished by using a .NET middleware layer to serve as a go-between for command line utilities, auxiliary Python scripts, and other programs that are embedded within the Docker image.

### Included Utilities
- [sbom2doc](https://github.com/anthonyharrison/sbom2doc) (installed via pip)

## Usage
The Harbor Integration Service is designed to run as a Docker container or K8s pod in any system or cluster that can reach the target Harbor instance. There MUST be a network route from the container to Harbor, including proper firewall exceptions or security group modifications if operating in a cloud environment.

This container can also be run directly alongside Harbor on the same virtual machine.

### Prerequisites
Before beginning, ensure that you have a Robot account set up in the Harbor UI. This account should have access to list repositories within the projects you wish to have access to, along with read access to artifact accessories and scans.

You will need the account name and associated secret for the robot account; these values will be passed to the command line in the next step.

For a step-by-step guide to set up your robot account, consult the [official documentation](https://goharbor.io/docs/2.15.0/working-with-projects/project-configuration/create-robot-accounts/).


### Container Start
To build and start the container, run the following commands, being sure to replace the environment variable values that contain your Harbor secrets:
```bash
cd HarborIntegrationService

docker build -t harborintegrationservice:latest .

docker run -d \
    -p 5038:5038 \
    -e HarborIntegration__RobotAccountName="<insert>" \
    -e HarborIntegration__RobotAccountSecret="<insert>" \
    -e HarborIntegration__HarborAddress="<insert FQDN>" \
    --restart always \
    --name harborintegrationservice \
    harborintegrationservice:latest
```

NOTE: This repository contains `appsettings` files that are pre-configured to use variable replacement syntax for the Octopus Deploy continuous deployment platform. These files will need to be adjusted to support variable replacement syntax from other pipeline hosts.

## Expanding and Customizing the API
At time of publishing, the Harbor Integration Service is limited to working with a single service family, `nedss-modernization`. This is set as the `ProjectName` value in the `ArtifactRequestModel` object by default. Accordingly, the API is limited to the following NBS services, as outlined in the SourceContainer enumerable:

```C#
/// <summary>
///     Name of the container for which you want to generate an artifact.
///     Select your chosen container from the dropdown.
///     Can't find it? Add it to the SourceContainer enum.
///     Make sure to fill out the extra extensions!
/// </summary>
public enum SourceContainer
{
    CaseNotificationService,
    DataCompareAPIService,
    DataCompareProcessorService,
    DataExtractionService,
    DataIngestionService,
    DataProcessingService,
    DeduplicationAPI,
    Elasticsearch,
    InvestigationReporting,
    LDFDataReporting,
    Liquibase,
    ModernizationAPI,
    NBSGateway,
    NiFi,
    NNDDataExchangeService,
    NNDService,
    ObservationReporting,
    OrganizationReporting,
    PageBuilderAPI,
    PersonReporting,
    PostProcessingReporting,
    ReportExecution,
    ReportingPipeline,
    XMLHL7Parser
}
```

To add additional services within `nedss-modernization`, they can be added directly to this enumerable, taking care to make additional changes to the associated extension methods in `SourceContainer.cs`.

To expand this microservice to work with other projects in Harbor, the `SourceContainer.cs` object can be duplicated or otherwise expanded, with appropriate changes made to conditionally switch objects based on the value of `ProjectName` passed into the `ArtifactRequestModel`.