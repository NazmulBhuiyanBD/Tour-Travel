using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class AddHotelAmenities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Amenities",
                table: "Hotels",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Amenities",
                table: "Hotels");
        }
    }
}
