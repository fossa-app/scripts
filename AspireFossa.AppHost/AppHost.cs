using CommunityToolkit.Aspire.Hosting.PowerShell;
using System.Management.Automation;

var builder = DistributedApplication.CreateBuilder(args);

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

var app = builder.Build();

await app.RunAsync();