namespace HarborIntegrationService.Enum;

/// <summary>
///     Name of the container for which you want to generate an artifact.
///     Select your chosen container from the dropdown.
///     Can't find it? Add it to the SourceContainer enum.
///     Make sure to fill out the extra extensions!
/// </summary>
public enum SourceContainer
{
    CaseNotificationService,
    DataCompareAPIService,
    DataCompareProcessorService,
    DataExtractionService,
    DataIngestionService,
    DataProcessingService,
    DeduplicationAPI,
    Elasticsearch,
    InvestigationReporting,
    LDFDataReporting,
    Liquibase,
    ModernizationAPI,
    NBSGateway,
    NiFi,
    NNDDataExchangeService,
    NNDService,
    ObservationReporting,
    OrganizationReporting,
    PageBuilderAPI,
    PersonReporting,
    PostProcessingReporting,
    ReportExecution,
    ReportingPipeline,
    XMLHL7Parser
}

public static class SourceContainerExtensions
{
    public static string Project(this SourceContainer sourceContainer)
    {
        switch (sourceContainer)
        {
            case SourceContainer.CaseNotificationService:
                return "nbs7-case-notification-service";
            case SourceContainer.DataCompareAPIService:
                return "nbs7-data-compare-api-service";
            case SourceContainer.DataCompareProcessorService:
                return "nbs7-data-compare-processor-service";
            case SourceContainer.DataExtractionService:
                return "nbs7-data-extraction-service";
            case SourceContainer.DataIngestionService:
                return "nbs7-dataingestion-service";
            case SourceContainer.DataProcessingService:
                return "nbs7-data-processing-service";
            case SourceContainer.DeduplicationAPI:
                return "nbs7-deduplication-api";
            case SourceContainer.Elasticsearch:
                return "nbs7-elasticsearch";
            case SourceContainer.InvestigationReporting:
                return "nbs7-investigation-reporting";
            case SourceContainer.LDFDataReporting:
                return "nbs7-ldf-data-reporting";
            case SourceContainer.Liquibase:
                return "nbs7-liquibase";
            case SourceContainer.ModernizationAPI:
                return "nbs7-modernization-api";
            case SourceContainer.NBSGateway:
                return "nbs7-nbs-gateway";
            case SourceContainer.NiFi:
                return "nbs7-nifi";
            case SourceContainer.NNDDataExchangeService:
                return "nbs7-nnd-data-exchange-service";
            case SourceContainer.NNDService:
                return "nbs7-nnd-service";
            case SourceContainer.ObservationReporting:
                return "nbs7-observation-reporting";
            case SourceContainer.OrganizationReporting:
                return "nbs7-organization-reporting";
            case SourceContainer.PageBuilderAPI:
                return "nbs7-page-builder-api";
            case SourceContainer.PersonReporting:
                return "nbs7-person-reporting";
            case SourceContainer.PostProcessingReporting:
                return "nbs7-post-processing-reporting";
            case SourceContainer.ReportExecution:
                return "nbs7-report-execution";
            case SourceContainer.ReportingPipeline:
                return "nbs7-reporting-pipeline";
            case SourceContainer.XMLHL7Parser:
                return "nbs7-xml-hl7-parser";
            default:
                return "";
        }
    }
}