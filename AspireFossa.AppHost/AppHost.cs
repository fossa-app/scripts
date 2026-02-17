using CommunityToolkit.Aspire.Hosting.PowerShell;
using System.Management.Automation;
using DotNetEnv;

var builder = DistributedApplication.CreateBuilder(args);

var envVars = Env.TraversePath().Load();

var ps = builder.AddPowerShell("ps", PSLanguageMode.FullLanguage);

var startScript = ps.AddScript("Start", """
    ../Start.ps1
""")
    .WithArgs();

var api = builder.AddProject<Projects.API_Web>("api")
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