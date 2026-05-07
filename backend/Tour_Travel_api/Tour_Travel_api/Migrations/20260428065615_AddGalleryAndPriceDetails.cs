using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class AddGalleryAndPriceDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "GalleryImages",
                table: "Tours",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GalleryImages",
                table: "Hotels",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PricePerNight",
                table: "Hotels",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GalleryImages",
                table: "Tours");

            migrationBuilder.DropColumn(
                name: "GalleryImages",
                table: "Hotels");

            migrationBuilder.DropColumn(
                name: "PricePerNight",
                table: "Hotels");
        }
    }
}
