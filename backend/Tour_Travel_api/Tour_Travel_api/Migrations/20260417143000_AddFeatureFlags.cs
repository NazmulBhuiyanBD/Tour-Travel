using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    public partial class AddFeatureFlags : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsTopDestination",
                table: "Tours",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsFeatured",
                table: "Hotels",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsPopular",
                table: "Flights",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsTopDestination",
                table: "Tours");

            migrationBuilder.DropColumn(
                name: "IsFeatured",
                table: "Hotels");

            migrationBuilder.DropColumn(
                name: "IsPopular",
                table: "Flights");
        }
    }
}
