using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Tour___Travel_api.Migrations
{
    /// <inheritdoc />
    public partial class RemoveVisaModule : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "VisaApplications");

            migrationBuilder.DropTable(
                name: "VisaDocuments");

            migrationBuilder.DropTable(
                name: "Visas");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "VisaDocuments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    FilePath = table.Column<string>(type: "text", nullable: false),
                    VisaApplicationId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VisaDocuments", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Visas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Country = table.Column<string>(type: "text", nullable: false),
                    CountryCode = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    Fee = table.Column<decimal>(type: "numeric", nullable: false),
                    ImageUrl = table.Column<string>(type: "text", nullable: false),
                    ProcessingTime = table.Column<string>(type: "text", nullable: false),
                    ValidityDays = table.Column<int>(type: "integer", nullable: false),
                    VisaType = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Visas", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "VisaApplications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    VisaId = table.Column<int>(type: "integer", nullable: false),
                    AdultsCount = table.Column<int>(type: "integer", nullable: false),
                    AppliedDate = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    ApplyRef = table.Column<string>(type: "text", nullable: false),
                    ChildrenCount = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<string>(type: "text", nullable: false),
                    TotalFee = table.Column<decimal>(type: "numeric", nullable: false),
                    TravelDate = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    UserId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VisaApplications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_VisaApplications_Visas_VisaId",
                        column: x => x.VisaId,
                        principalTable: "Visas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_VisaApplications_VisaId",
                table: "VisaApplications",
                column: "VisaId");
        }
    }
}
