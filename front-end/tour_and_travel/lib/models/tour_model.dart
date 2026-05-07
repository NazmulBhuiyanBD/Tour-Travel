class TourModel {
  int? id;
  String? title;
  String? description;
  int? durationDays;
  double? price;
  String? itinerary;
  bool? isTopDestination;
  String? imageUrl;
  String? galleryImages;

  TourModel({
    this.id,
    this.title,
    this.description,
    this.durationDays,
    this.price,
    this.itinerary,
    this.isTopDestination,
    this.imageUrl,
    this.galleryImages,
  });

  TourModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    durationDays = json['durationDays'];
    price = (json['price'] as num?)?.toDouble();
    itinerary = json['itinerary'];
    isTopDestination = json['isTopDestination'];
    imageUrl = json['imageUrl'];
    galleryImages = json['galleryImages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['durationDays'] = durationDays;
    data['price'] = price;
    data['itinerary'] = itinerary;
    data['isTopDestination'] = isTopDestination;
    data['imageUrl'] = imageUrl;
    data['galleryImages'] = galleryImages;
    return data;
  }

  List<String> get galleryList {
    if (galleryImages == null || galleryImages!.isEmpty) {
      return imageUrl != null ? [imageUrl!] : [];
    }
    return galleryImages!.split(',').map((e) => e.trim()).toList();
  }
}
