using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Logging;
using System.Net;
using Xunit;

namespace CGA.MetrologySystem.Tests;

public sealed class WebApplicationTests : IClassFixture<CgaWebApplicationFactory>
{
    private readonly HttpClient _client;

    public WebApplicationTests(CgaWebApplicationFactory factory)
    {
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    [Fact]
    public async Task Home_returns_success()
    {
        using var response = await _client.GetAsync("/");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Home_contains_product_name()
    {
        var html = await _client.GetStringAsync("/");

        Assert.Contains("CGA Metrology System", html, StringComparison.Ordinal);
    }

    [Theory]
    [InlineData("ASP.NET Core")]
    [InlineData("Docker")]
    [InlineData("Kubernetes")]
    [InlineData("Argo CD")]
    public async Task Home_lists_project_technology(string technology)
    {
        var html = await _client.GetStringAsync("/");

        Assert.Contains(technology, html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Privacy_route_returns_success()
    {
        using var response = await _client.GetAsync("/Home/Privacy");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Health_route_returns_success_without_sensitive_details()
    {
        using var response = await _client.GetAsync("/health");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", body);
    }
}

public sealed class CgaWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.ConfigureLogging(logging =>
        {
            logging.ClearProviders();
            logging.AddConsole();
        });
    }
}
