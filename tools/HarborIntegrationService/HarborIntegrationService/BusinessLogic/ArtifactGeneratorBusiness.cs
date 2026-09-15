using HarborIntegrationService.Models;

namespace HarborIntegrationService.Business;

/// <inheritdoc/>
public class ArtifactGeneratorBusiness : IArtifactGeneratorBusiness
{
    private readonly ICommandLineInvocationBusiness _commandLineInvocationBusiness;
    private readonly IHarborIntegrationBusiness _harborIntegrationBusiness;
    private readonly ILogger<ArtifactGeneratorBusiness> _logger;

    public ArtifactGeneratorBusiness(ILogger<ArtifactGeneratorBusiness> logger,
        IHarborIntegrationBusiness harborIntegrationBusiness,
        ICommandLineInvocationBusiness commandLineInvocationBusiness)
    {
        _logger = logger;
        _harborIntegrationBusiness = harborIntegrationBusiness;
        _commandLineInvocationBusiness = commandLineInvocationBusiness;
    }

    /// <inheritdoc/>
    public async Task<string> GetBillOfMaterials(ArtifactRequestModel requestModel)
    {
        try
        {
            var sbomReference = await _harborIntegrationBusiness.GetSbomArtifactReference(requestModel);
            var sbomArtifact = await _harborIntegrationBusiness.GetSbomArtifact(requestModel, sbomReference);
            var artifactResult = _commandLineInvocationBusiness.InvokeSbom2Doc(sbomArtifact,
                requestModel.SourceContainer, requestModel.ArtifactFormat);

            return artifactResult;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<string> GetVulnerabilities(ArtifactRequestModel requestModel)
    {
        throw new NotImplementedException();
    }

    /// <inheritdoc/>
    public async Task<string> GetLicense(ArtifactRequestModel requestModel)
    {
        throw new NotImplementedException();
    }
}