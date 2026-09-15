using System.Net.Http.Headers;
using System.Text;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using HarborIntegrationService.Configuration;
using HarborIntegrationService.Enum;
using HarborIntegrationService.Models;

/// <inheritdoc/>
public class HarborIntegrationBusiness : IHarborIntegrationBusiness
{
    private static HttpClient HarborClient;
    private readonly ILogger<HarborIntegrationBusiness> _logger;

    private readonly HarborIntegrationSettings _settings;
    private readonly string RobotAccountName;
    private readonly string RobotAccountSecret;

    /// <inheritdoc/>
    public HarborIntegrationBusiness(IOptions<HarborIntegrationSettings> settings,
        ILogger<HarborIntegrationBusiness> logger)
    {
        _settings = settings.Value;
        _logger = logger;
        RobotAccountName = _settings.RobotAccountName;
        RobotAccountSecret = _settings.RobotAccountSecret;
        HarborClient = new HttpClient
        {
            BaseAddress = _settings.HarborAddress
        };
        HarborClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Basic",
            Convert.ToBase64String(Encoding.UTF8.GetBytes(RobotAccountName + ":" + RobotAccountSecret))
        );
    }

    /// <inheritdoc/>
    public async Task<string> GetSbomArtifactReference(ArtifactRequestModel requestModel)
    {
        try
        {
            var request =
                $"projects/{requestModel.ProjectName}/repositories/{requestModel.SourceContainer.Project()}/artifacts?page=1&page_size=10&with_tag=true&with_label=false&with_scan_overview=false&with_sbom_overview=true&with_immutable_status=false&with_accessory=false";
            using var response = await HarborClient.GetAsync(request);

            var jsonResponse = await response.Content.ReadAsStringAsync();
            dynamic json = JsonConvert.DeserializeObject(jsonResponse);

            return json[0]["sbom_overview"]["sbom_digest"];
        }
        catch (NullReferenceException ex)
        {
            _logger.LogError(ex.Message);
            throw new Exception($"No SBOM generated for project {requestModel.ProjectName}");
        }
        catch (ArgumentOutOfRangeException ex)
        {
            _logger.LogError(ex.Message);
            throw new ArgumentOutOfRangeException($"Project {requestModel.ProjectName} does not exist or no SBOM is present.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }

    /// <inheritdoc/>
    public async Task<string> GetSbomArtifact(ArtifactRequestModel requestModel, string reference)
    {
        try
        {
            var jsonPath = requestModel.SourceContainer + "_sbom_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") +
                           ".json";
            var request =
                $"projects/{requestModel.ProjectName}/repositories/{requestModel.SourceContainer.Project()}/artifacts/{reference}/additions/sbom";
            using var response = await HarborClient.GetAsync(request);

            var jsonResponse = await response.Content.ReadAsStreamAsync();

            using var fileStream = new FileStream(jsonPath, FileMode.Create, FileAccess.Write, FileShare.None);

            await jsonResponse.CopyToAsync(fileStream);

            return jsonPath;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }
}