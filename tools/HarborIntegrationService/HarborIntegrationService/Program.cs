using System.Reflection;
using System.Text.Json.Serialization;
using HarborIntegrationService.Business;
using HarborIntegrationService.Configuration;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
});
builder.Services.Configure<HarborIntegrationSettings>(
    builder.Configuration.GetSection("HarborIntegration")
);

builder.Services.AddScoped<IArtifactGeneratorBusiness, ArtifactGeneratorBusiness>();
builder.Services.AddScoped<ICommandLineInvocationBusiness, CommandLineInvocationBusiness>();
builder.Services.AddScoped<IHarborIntegrationBusiness, HarborIntegrationBusiness>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Construct the path to the compiled XML documentation file
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);

    // Inject the XML comments into Swagger
    options.IncludeXmlComments(xmlPath);
});

var app = builder.Build();

//app.MapOpenApi();
app.UseSwagger();
app.UseSwaggerUI();

// Configure the HTTP request pipeline.
/*if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}*/

//app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();