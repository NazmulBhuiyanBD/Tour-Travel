using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateVisaSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CountryCode",
                table: "Visas",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Visas",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ProcessingTime",
                table: "Visas",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "ValidityDays",
                table: "Visas",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "AdultsCount",
                table: "VisaApplications",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "ApplyRef",
                table: "VisaApplications",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "ChildrenCount",
                table: "VisaApplications",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "TotalFee",
                table: "VisaApplications",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "TravelDate",
                table: "VisaApplications",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CountryCode",
                table: "Visas");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Visas");

            migrationBuilder.DropColumn(
                name: "ProcessingTime",
                table: "Visas");

            migrationBuilder.DropColumn(
                name: "ValidityDays",
                table: "Visas");

            migrationBuilder.DropColumn(
                name: "AdultsCount",
                table: "VisaApplications");

            migrationBuilder.DropColumn(
                name: "ApplyRef",
                table: "VisaApplications");

            migrationBuilder.DropColumn(
                name: "ChildrenCount",
                table: "VisaApplications");

            migrationBuilder.DropColumn(
                name: "TotalFee",
                table: "VisaApplications");

            migrationBuilder.DropColumn(
                name: "TravelDate",
                table: "VisaApplications");
        }
    }
}
