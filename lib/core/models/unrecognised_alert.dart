/// A financial-looking alert no parser template matched (doc.md §15.4).
class UnrecognisedAlert {
  final String id;
  final String sender;
  final String rawMessage;
  final DateTime receivedAt;

  const UnrecognisedAlert({
    required this.id,
    required this.sender,
    required this.rawMessage,
    required this.receivedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'rawMessage': rawMessage,
        'receivedAt': receivedAt.toIso8601String(),
      };

  factory UnrecognisedAlert.fromJson(Map<String, dynamic> json) {
    return UnrecognisedAlert(
      id: json['id'] as String,
      sender: json['sender'] as String,
      rawMessage: json['rawMessage'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }
}
