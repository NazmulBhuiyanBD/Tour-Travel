using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class AddTourStartEndFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "EndPoint",
                table: "Tours",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "StartPoint",
                table: "Tours",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EndPoint",
                table: "Tours");

            migrationBuilder.DropColumn(
                name: "StartPoint",
                table: "Tours");
        }
    }
}
