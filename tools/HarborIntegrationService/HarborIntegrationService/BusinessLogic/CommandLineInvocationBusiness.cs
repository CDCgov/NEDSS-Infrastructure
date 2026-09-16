using System.Diagnostics;
using HarborIntegrationService.Enum;

/// <inheritdoc/>
public class CommandLineInvocationBusiness : ICommandLineInvocationBusiness
{
    private readonly ILogger<CommandLineInvocationBusiness> _logger;

    public CommandLineInvocationBusiness(ILogger<CommandLineInvocationBusiness> logger)
    {
        _logger = logger;
    }

    /// <inheritdoc/>
    public string InvokeSbom2Doc(string inputFileName, SourceContainer sourceContainer, ArtifactFormat desiredFormat)
    {
        var outputFile = sourceContainer + "_sbom_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") +
                         desiredFormat.FileExtension();
        var args =
            $"--input-file /app/{inputFileName} --format {desiredFormat.FormatArgument()} --output-file {outputFile}";

        try
        {
            var processStartInfo = new ProcessStartInfo
            {
                FileName = "sbom2doc",
                Arguments = args,
                RedirectStandardError = true,
                RedirectStandardOutput = true
            };

            using (var process = new Process { StartInfo = processStartInfo })
            {
                process.Start();

                var output = process.StandardOutput.ReadToEnd();
                var error = process.StandardError.ReadToEnd();

                process.WaitForExit();

                if (process.ExitCode == 0)
                {
                    _logger.LogDebug($"Successfully generated SBOM Artifact: {outputFile}");
                    _logger.LogDebug($"SBOM2Doc Output: {output}");
                }
                else
                {
                    _logger.LogError($"SBOM2Doc failed with exit code: {process.ExitCode}");
                    _logger.LogError($"Arguments: {args}");
                    _logger.LogError("Error Output:");
                    _logger.LogError(error);
                }
            }

            return outputFile;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }
}