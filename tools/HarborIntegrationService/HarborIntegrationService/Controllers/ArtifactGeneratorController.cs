using HarborIntegrationService.Enum;
using HarborIntegrationService.Models;
using Microsoft.AspNetCore.Mvc;

namespace HarborIntegrationService.Controllers;

[ApiController]
[Route("[controller]")]
public class ArtifactGeneratorController : ControllerBase
{
    private readonly IArtifactGeneratorBusiness _artifactGeneratorBusiness;
    private readonly ILogger<ArtifactGeneratorController> _logger;


    public ArtifactGeneratorController(ILogger<ArtifactGeneratorController> logger,
        IArtifactGeneratorBusiness artifactGeneratorBusiness)
    {
        _logger = logger;
        _artifactGeneratorBusiness = artifactGeneratorBusiness;
    }

    /// <summary>
    ///     Commands the generation of a formatted artifact contingent on the successful retrieval of a digest that exists in
    ///     Harbor.
    /// </summary>
    /// <remarks>
    ///     This call is dependent on the scan for the artifact having already been completed in Harbor. It is currently not
    ///     capable of kicking off a bill of materials scan on its own.
    /// </remarks>
    /// <param name="model"></param>
    /// <returns>A file stream with correct MIME value for retrieval either via direct API call or through the UI.</returns>
    /// <response code="200"></response>
    /// <response code="404">
    ///     No artifact reference currently exists for the project and repository selected. Make sure Harbor
    ///     has completed its scans and try again later.
    /// </response>
    /// <response code="500">Something has gone terribly wrong in the backend. Please reach out to DevSecOps for assistance.</response>
    [HttpPost(Name = "GenerateArtifact")]
    [ProducesResponseType(typeof(FileStreamResult), 200)]
    [ProducesResponseType(404)]
    [ProducesResponseType(500)]
    public async Task<IActionResult> GenerateArtifact([FromForm] ArtifactRequestModel model)
    {
        string resultPath;
        try
        {
            _logger.LogDebug(
                $"Received request for {model.ArtifactType} from {model.SourceContainer} container in project {model.ProjectName}.");

            switch (model.ArtifactType)
            {
                case ArtifactType.SBOM:
                    resultPath = await _artifactGeneratorBusiness.GetBillOfMaterials(model);
                    break;
                case ArtifactType.License:
                    resultPath = await _artifactGeneratorBusiness.GetLicense(model);
                    break;
                case ArtifactType.Vulnerabilities:
                    resultPath = await _artifactGeneratorBusiness.GetVulnerabilities(model);
                    break;
                default:
                    return BadRequest();
            }

            _logger.LogDebug($"Resulting file is at path: {resultPath}");

            if (!System.IO.File.Exists(resultPath))
                return NotFound();

            var fileStream = new FileStream(resultPath, FileMode.Open, FileAccess.Read, FileShare.None);
            var contentType = model.ArtifactFormat.MimeType();

            return new FileStreamResult(fileStream, contentType) { FileDownloadName = resultPath };
        }
        catch (ArgumentOutOfRangeException)
        {
            return NotFound();
        }
        catch (Exception ex)
        {
            return Problem(ex.Message, title: "An unexpected error occurred.");
        }
    }
}