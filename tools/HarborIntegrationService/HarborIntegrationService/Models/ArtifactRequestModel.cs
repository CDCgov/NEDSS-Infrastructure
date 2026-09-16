using System.ComponentModel;
using HarborIntegrationService.Enum;

namespace HarborIntegrationService.Models;

public class ArtifactRequestModel
{
    /// <summary>
    ///     Name of the overarching project in which the target container resides.
    /// </summary>
    /// <example>nedss-modernization</example>
    [DefaultValue("nedss-modernization")]
    public string ProjectName { get; set; } = "nedss-modernization";

    /// <summary>
    ///     Name of the container for which you want to generate an artifact.
    ///     Select your chosen container from the dropdown.
    ///     Can't find it? Add it to the SourceContainer enum.
    ///     Make sure to fill out the extra extensions!
    /// </summary>
    public SourceContainer SourceContainer { get; set; }

    /// <summary>
    ///     The type of artifact you want to generate using sbom2doc.
    ///     SBOMs are the default. Future support is planned for extracting
    ///     vulnerability reports and license information from Harbor.
    /// </summary>
    public ArtifactType ArtifactType { get; set; }

    /// <summary>
    ///     The file format you'd like your SBOM artifact to be delivered in.
    ///     The list provided comprises the complete list of support for the sbom2doc utility.
    /// </summary>
    public ArtifactFormat ArtifactFormat { get; set; }
}