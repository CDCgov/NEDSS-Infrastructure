using HarborIntegrationService.Models;

/// <summary>
/// Contains methods that invoke an HttpClient for interacting with the Harbor API.
/// </summary>
public interface IHarborIntegrationBusiness
{
    /// <summary>
    /// Polls Harbor for a collection of artifacts associated with an image. Attempts to parse an SBOM artifact digest reference from the result.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <returns></returns>
    public Task<string> GetSbomArtifactReference(ArtifactRequestModel requestModel);

    /// <summary>
    /// Fetches an SBOM json file from Harbor using the reference parameter.
    /// </summary>
    /// <param name="requestModel"></param>
    /// <param name="reference">The sha256 reference to the SBOM digest.</param>
    /// <returns></returns>
    public Task<string> GetSbomArtifact(ArtifactRequestModel requestModel, string reference);
}