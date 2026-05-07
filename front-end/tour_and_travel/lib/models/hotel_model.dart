class HotelModel {
  int? id;
  String? name;
  String? location;
  String? description;
  double? rating;
  String? imageUrl;
  String? galleryImages;
  double? pricePerNight;
  bool? isFeatured;

  HotelModel({
    this.id,
    this.name,
    this.location,
    this.description,
    this.rating,
    this.imageUrl,
    this.galleryImages,
    this.pricePerNight,
    this.isFeatured,
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    description = json['description'];
    rating = (json['rating'] as num?)?.toDouble();
    imageUrl = json['imageUrl'];
    galleryImages = json['galleryImages'];
    pricePerNight = (json['pricePerNight'] as num?)?.toDouble();
    isFeatured = json['isFeatured'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['description'] = description;
    data['rating'] = rating;
    data['imageUrl'] = imageUrl;
    data['galleryImages'] = galleryImages;
    data['pricePerNight'] = pricePerNight;
    data['isFeatured'] = isFeatured;
    return data;
  }

  List<String> get galleryList {
    if (galleryImages == null || galleryImages!.isEmpty) {
      return imageUrl != null ? [imageUrl!] : [];
    }
    return galleryImages!.split(',').map((e) => e.trim()).toList();
  }
}
