class TourModel {
  int? id;
  String? title;
  String? description;
  int? durationDays;
  double? price;
  String? startPoint;
  String? endPoint;
  String? itinerary;
  bool? isTopDestination;
  String? imageUrl;
  String? galleryImages;
  DateTime? startDate;
  int? vacancy;

  TourModel({
    this.id,
    this.title,
    this.description,
    this.durationDays,
    this.price,
    this.startPoint,
    this.endPoint,
    this.itinerary,
    this.isTopDestination,
    this.imageUrl,
    this.galleryImages,
    this.startDate,
    this.vacancy,
  });

  TourModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    durationDays = json['durationDays'];
    price = (json['price'] as num?)?.toDouble();
    startPoint = json['startPoint'];
    endPoint = json['endPoint'];
    itinerary = json['itinerary'];
    isTopDestination = json['isTopDestination'];
    imageUrl = json['imageUrl'];
    galleryImages = json['galleryImages'];
    startDate = json['startDate'] != null ? DateTime.tryParse(json['startDate'].toString()) : null;
    vacancy = json['vacancy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['durationDays'] = durationDays;
    data['price'] = price;
    data['startPoint'] = startPoint;
    data['endPoint'] = endPoint;
    data['itinerary'] = itinerary;
    data['isTopDestination'] = isTopDestination;
    data['imageUrl'] = imageUrl;
    data['galleryImages'] = galleryImages;
    data['startDate'] = startDate?.toIso8601String();
    data['vacancy'] = vacancy;
    return data;
  }

  List<String> get galleryList {
    if (galleryImages == null || galleryImages!.isEmpty) {
      return imageUrl != null ? [imageUrl!] : [];
    }
    return galleryImages!.split(',').map((e) => e.trim()).toList();
  }
}
