import 'package:blockchain_university_voting_system/utils/converter_util.dart';

class NotificationModel {
  final String _notificationID;
  final String _title;
  final String _message;
  final List<String>? _imageURLs;
  final String _senderID; // user id
  final List<String> _receiverIDs; // user id
  final String _type; // type of notification
  final DateTime _createdAt;
  final DateTime? _updatedAt;

  NotificationModel({
    required String notificationID,
    required String title,
    required String message,
    List<String>? imageURLs,
    required String senderID,
    required List<String> receiverIDs,
    required String type,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : _notificationID = notificationID,
       _title = title,
       _message = message,
       _imageURLs = imageURLs,
       _senderID = senderID,
       _receiverIDs = receiverIDs,
       _type = type,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  String get notificationID => _notificationID;
  String get title => _title;
  String get message => _message;
  List<String>? get imageURLs => _imageURLs;
  String get senderID => _senderID;
  List<String> get receiverIDs => _receiverIDs;
  String get type => _type;
  DateTime get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationID: json['notificationID'],
      title: json['title'],
      message: json['message'],
      imageURLs: json['imageURLs'],
      senderID: json['senderID'],
      receiverIDs: json['receiverIDs'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationID': _notificationID,
      'title': _title,
      'message': _message,
      'imageURLs': _imageURLs,
      'senderID': _senderID,
      'receiverIDs': _receiverIDs,
      'type': _type,
      'createdAt': ConverterUtil.dateTimeToBigInt(_createdAt),
      'updatedAt': _updatedAt != null ? ConverterUtil.dateTimeToBigInt(_updatedAt) : null,
    };
  }

}