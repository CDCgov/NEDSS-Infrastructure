using HarborIntegrationService.Models;

/// <summary>
/// 
/// </summary>
public interface IArtifactGeneratorBusiness
{
    /// <summary>
    /// Generates a human-readable Software Bill of Materials artifact using sbom2doc.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <returns></returns>
    public Task<string> GetBillOfMaterials(ArtifactRequestModel requestModel);

    /// <summary>
    /// Not yet implemented.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <returns></returns>
    public Task<string> GetVulnerabilities(ArtifactRequestModel requestModel);

    /// <summary>
    /// Not yet implemented.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <returns></returns>
    public Task<string> GetLicense(ArtifactRequestModel requestModel);
}