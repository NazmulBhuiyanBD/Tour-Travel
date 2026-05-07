using System.Text;
using System.Text.Json;

namespace TravelApp.Services
{
    public class PaymentService
    {
        private readonly HttpClient _http;

        public PaymentService(HttpClient http)
        {
            _http = http;
        }

        public async Task<string> Pay(decimal amount)
        {
            var data = new
            {
                total_amount = amount,
                currency = "BDT"
            };

            var content = new StringContent(
                JsonSerializer.Serialize(data),
                Encoding.UTF8,
                "application/json");

            var res = await _http.PostAsync("https://sandbox.sslcommerz.com", content);

            return await res.Content.ReadAsStringAsync();
        }
    }
}