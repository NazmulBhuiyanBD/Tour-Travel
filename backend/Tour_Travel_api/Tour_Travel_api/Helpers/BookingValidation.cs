namespace TravelApp.Helpers
{
    public static class BookingValidation
    {
        public const int MaxQuantityPerBooking = 4;
        public const int MaxHotelNights = 7;

        public static void ValidateQuantity(int quantity, string label = "quantity")
        {
            if (quantity < 1 || quantity > MaxQuantityPerBooking)
                throw new Exception($"You can book between 1 and {MaxQuantityPerBooking} {label} per booking.");
        }

        public static int ValidateHotelStay(DateTime checkIn, DateTime checkOut)
        {
            if (checkOut.Date <= checkIn.Date)
                throw new Exception("Check-out must be after check-in.");

            var nights = (checkOut.Date - checkIn.Date).Days;
            if (nights > MaxHotelNights)
                throw new Exception($"Maximum stay is {MaxHotelNights} nights per booking.");

            return nights;
        }
    }
}
