using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentDetailsToBookings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "TourBookings",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TransactionId",
                table: "TourBookings",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "HotelBookings",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TransactionId",
                table: "HotelBookings",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PaymentMethod",
                table: "FlightBookings",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TransactionId",
                table: "FlightBookings",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "TourBookings");

            migrationBuilder.DropColumn(
                name: "TransactionId",
                table: "TourBookings");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "HotelBookings");

            migrationBuilder.DropColumn(
                name: "TransactionId",
                table: "HotelBookings");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "FlightBookings");

            migrationBuilder.DropColumn(
                name: "TransactionId",
                table: "FlightBookings");
        }
    }
}
