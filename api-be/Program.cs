var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.UseHttpsRedirection();


app.MapGet("/health", () => Results.Ok("Healthy"))
   .WithName("HealthCheck");

app.MapGet("/", () =>
{
    return "my api-be";
})
.WithName("Home");

app.Run();