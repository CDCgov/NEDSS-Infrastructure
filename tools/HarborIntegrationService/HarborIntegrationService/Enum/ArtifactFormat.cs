namespace HarborIntegrationService.Enum;

/// <summary>
///     The file format you'd like your SBOM artifact to be delivered in.
///     The list provided comprises the complete list of support for the sbom2doc utility.
/// </summary>
public enum ArtifactFormat
{
    XLSX,
    HTML,
    JSON,
    Markdown,
    PDF
}

public static class ArtifactFormatExtensions
{
    /// <summary>
    ///     Returns the correct MimeType value for processing by the browser or API client.
    /// </summary>
    /// <param name="artifactFormat"></param>
    /// <returns></returns>
    public static string MimeType(this ArtifactFormat artifactFormat)
    {
        switch (artifactFormat)
        {
            case ArtifactFormat.XLSX:
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case ArtifactFormat.HTML:
                return "text/html";
            case ArtifactFormat.JSON:
                return "application/json";
            case ArtifactFormat.Markdown:
                return "text/markdown";
            case ArtifactFormat.PDF:
                return "application/pdf";
            default:
                return "text/plain";
        }
    }

    /// <summary>
    ///     Sbom2doc requires specific format strings as arguments. This helper method takes care of formatting.
    /// </summary>
    /// <param name="artifactFormat"></param>
    /// <returns></returns>
    public static string FormatArgument(this ArtifactFormat artifactFormat)
    {
        switch (artifactFormat)
        {
            case ArtifactFormat.Markdown:
                return "markdown";
            case ArtifactFormat.XLSX:
                return "excel";
            default:
                return artifactFormat.ToString().ToLower();
        }
    }

    /// <summary>
    ///     Returns the correctly formatted file extension for appending to the file path.
    /// </summary>
    /// <param name="artifactFormat"></param>
    /// <returns></returns>
    public static string FileExtension(this ArtifactFormat artifactFormat)
    {
        switch (artifactFormat)
        {
            case ArtifactFormat.Markdown:
                return ".md";
            default:
                return "." + artifactFormat.ToString().ToLower();
        }
    }
}