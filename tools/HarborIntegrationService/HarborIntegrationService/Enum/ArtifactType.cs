namespace HarborIntegrationService.Enum;

/// <summary>
///     The type of artifact you want to generate using sbom2doc.
///     SBOMs are the default. Future support is planned for extracting
///     vulnerability reports and license information from Harbor.
/// </summary>
public enum ArtifactType
{
    SBOM,
    Vulnerabilities,
    License
}