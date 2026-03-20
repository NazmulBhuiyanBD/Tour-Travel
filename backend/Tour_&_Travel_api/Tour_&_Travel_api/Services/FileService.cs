namespace TravelApp.Services
{
    public class FileService
    {
        public async Task<string> Upload(IFormFile file)
        {
            var folder = "wwwroot/images";

            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            var fileName = Guid.NewGuid() + Path.GetExtension(file.FileName);
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream);

            return "/images/" + fileName;
        }
    }
}