namespace HarborIntegrationService.Configuration;

/// <summary>
/// Configuration object for the settings required to integrate with the Harbor API.
/// </summary>
public class HarborIntegrationSettings
{
    /// <summary>
    /// Username of the robot account set up in the Harbor UI. Required for Harbor API access.
    /// </summary>
    public string RobotAccountName { get; set; }

    /// <summary>
    /// Secret/Password for the robot account set up in the Harbor UI. Required for Harbor API access.
    /// </summary>
    public string RobotAccountSecret { get; set; }

    /// <summary>
    /// The address that will become the base for the HttpClient object used to communicate with Harbor.
    /// 
    /// This address should include the '/api/v2.0/' suffix.
    /// </summary>
    public Uri HarborAddress { get; set; }
}