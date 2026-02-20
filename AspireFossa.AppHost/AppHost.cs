using CommunityToolkit.Aspire.Hosting.PowerShell;
using System.Management.Automation;
using DotNetEnv;
using System.IO;
using System.Text.Json.Nodes;

var builder = DistributedApplication.CreateBuilder(args);

var envVars = Env.TraversePath().Load();

var kickstartPath = Path.Combine(builder.Environment.ContentRootPath, "..", "kickstart", "kickstart.json");
var kickstartJson = await File.ReadAllTextAsync(kickstartPath);
var kickstartNode = JsonNode.Parse(kickstartJson);
var apiKey = kickstartNode?["variables"]?["apiKey"]?.GetValue<string>() ?? "047a124c-2dbc-4b68-84cc-55f9a204f4ea";

var ps = builder.AddPowerShell("ps", PSLanguageMode.FullLanguage);

var startScript = ps.AddScript("Start", """
    ../Start.ps1
""")
    .WithArgs();

var api = builder.AddProject<Projects.API_Web>("api")
    .WithEnvironment("Identity__RootAddress", "http://localhost:9011/")
    .WithEnvironment("Identity__ApiKey", apiKey)
    .WithHttpHealthCheck("/healthchecks")
    .WithExternalHttpEndpoints()
    .WaitFor(ps)
    .WaitForCompletion(startScript);

foreach (var envVar in envVars)
{
    api.WithEnvironment(envVar.Key, envVar.Value);
}

var app = builder.Build();

await app.RunAsync();