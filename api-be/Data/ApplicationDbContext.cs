using Microsoft.EntityFrameworkCore;
using api_be.Models;

namespace api_be.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; } = null!;
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure decimal precision for Price property
        modelBuilder.Entity<Product>()
            .Property(p => p.Price)
            .HasPrecision(18, 2);
        
        // Seed some initial data
        modelBuilder.Entity<Product>().HasData(
            new Product 
            { 
                Id = 1, 
                Name = "Test Product 1", 
                Description = "This is a test product", 
                Price = 19.99m,
                CreatedAt = new DateTime(2025, 1, 1) // Fixed date for seeding
            },
            new Product 
            { 
                Id = 2, 
                Name = "Test Product 2", 
                Description = "Another test product", 
                Price = 29.99m,
                CreatedAt = new DateTime(2025, 1, 1) // Fixed date for seeding 
            }
        );
    }
}
