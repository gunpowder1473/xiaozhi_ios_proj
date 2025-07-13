class XiaozhiConfig {
  final id;
  final name;
  final websocketUrl;
  final otaUrl;
  final macAddress;
  final token;
  
  XiaozhiConfig({
    required this.id,
    required this.name,
    required this.websocketUrl,
    required this.otaUrl,
    required this.macAddress,
    required this.token,
  });
  
  factory XiaozhiConfig.fromJson(Map<String, dynamic> json) {
    return XiaozhiConfig(
      id: json['id'],
      name: json['name'],
      websocketUrl: json['websocketUrl'],
      otaUrl: json['otaUrl'],
      macAddress: json['macAddress'],
      token: json['token'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'websocketUrl': websocketUrl,
      'otaUrl': otaUrl,
      'macAddress': macAddress,
      'token': token,
    };
  }
  
  XiaozhiConfig copyWith({
    String? name,
    String? websocketUrl,
    String? otaUrl,
    String? macAddress,
    String? token,
  }) {
    return XiaozhiConfig(
      id: id,
      name: name ?? this.name,
      websocketUrl: websocketUrl ?? this.websocketUrl,
      otaUrl: otaUrl ?? this.otaUrl,
      macAddress: macAddress ?? this.macAddress,
      token: token ?? this.token,
    );
  }
}

