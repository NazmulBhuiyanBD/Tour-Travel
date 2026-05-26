using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Infrastructure;
using TravelApp.Data;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AppDbContext))]
    [Migration("20260523010000_AddHotelRoomConfiguration")]
    public partial class AddHotelRoomConfiguration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BedType",
                table: "Rooms",
                type: "text",
                nullable: false,
                defaultValue: "King Bed");

            migrationBuilder.AddColumn<bool>(
                name: "IsAc",
                table: "Rooms",
                type: "boolean",
                nullable: false,
                defaultValue: true);

            migrationBuilder.AddColumn<string>(
                name: "ViewType",
                table: "Rooms",
                type: "text",
                nullable: false,
                defaultValue: "City View");

            migrationBuilder.Sql("""
                UPDATE "Rooms"
                SET "Type" = 'Single Room'
                WHERE "Type" IS NULL OR "Type" = '' OR "Type" = 'Standard Room';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BedType",
                table: "Rooms");

            migrationBuilder.DropColumn(
                name: "IsAc",
                table: "Rooms");

            migrationBuilder.DropColumn(
                name: "ViewType",
                table: "Rooms");
        }
    }
}
