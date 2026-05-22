using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    public partial class BookingInventoryAndSeatClasses : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AvailableRooms",
                table: "Hotels",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "RoomCount",
                table: "HotelBookings",
                type: "integer",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<DateTime>(
                name: "StartDate",
                table: "Tours",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "Vacancy",
                table: "Tours",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "ParticipantCount",
                table: "TourBookings",
                type: "integer",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalPrice",
                table: "TourBookings",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "SeatClass",
                table: "FlightBookings",
                type: "text",
                nullable: false,
                defaultValue: "Economy");

            migrationBuilder.CreateTable(
                name: "FlightSeatClasses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FlightId = table.Column<int>(type: "integer", nullable: false),
                    ClassName = table.Column<string>(type: "text", nullable: false),
                    AvailableSeats = table.Column<int>(type: "integer", nullable: false),
                    Price = table.Column<decimal>(type: "numeric", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FlightSeatClasses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FlightSeatClasses_Flights_FlightId",
                        column: x => x.FlightId,
                        principalTable: "Flights",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FlightSeatClasses_FlightId",
                table: "FlightSeatClasses",
                column: "FlightId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "FlightSeatClasses");

            migrationBuilder.DropColumn(name: "SeatClass", table: "FlightBookings");
            migrationBuilder.DropColumn(name: "TotalPrice", table: "TourBookings");
            migrationBuilder.DropColumn(name: "ParticipantCount", table: "TourBookings");
            migrationBuilder.DropColumn(name: "Vacancy", table: "Tours");
            migrationBuilder.DropColumn(name: "StartDate", table: "Tours");
            migrationBuilder.DropColumn(name: "RoomCount", table: "HotelBookings");
            migrationBuilder.DropColumn(name: "AvailableRooms", table: "Hotels");
        }
    }
}
