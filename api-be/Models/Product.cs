using System.ComponentModel.DataAnnotations;

namespace api_be.Models;

public class Product
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    public string? Description { get; set; }
    
    [Required]
    [Range(0.01, 10000.00)]
    public decimal Price { get; set; }
    
    // Use a fixed date for seeding data, don't use DateTime.UtcNow directly
    public DateTime CreatedAt { get; set; } = new DateTime(2025, 1, 1);
}
