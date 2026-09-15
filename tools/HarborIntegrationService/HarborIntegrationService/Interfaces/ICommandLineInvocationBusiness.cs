using HarborIntegrationService.Enum;

/// <summary>
/// Contains methods for invoking command line interface (CLI) utilities that are installed within the service container.
/// At present, the following utilities are available:
/// - sbom2doc (pip)
/// 
/// Modify the project Dockerfile to make additional utilities available. 
/// Follow the template in `InvokeSbom2Doc` to extend calling functionality.
/// </summary>
public interface ICommandLineInvocationBusiness
{
    /// <summary>
    /// Invokes the sbom2doc pip package using the chosen parameters.
    /// </summary>
    /// <param name="inputFileName">Input SBOM json file fetched from Harbor.</param>
    /// <param name="sourceContainer">Container for which this SBOM is being generated.</param>
    /// <param name="desiredFormat">Desired output format for the human-readable SBOM artifact.</param>
    /// <returns></returns>
    public string InvokeSbom2Doc(string inputFileName, SourceContainer sourceContainer, ArtifactFormat desiredFormat);
}