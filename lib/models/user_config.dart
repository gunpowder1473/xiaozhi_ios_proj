import 'dart:ffi';

class UserConfig {
  final id;
  final sysIconPath;
  final backgroundPath;
  final selfIconPath;
  
  UserConfig({
    required this.id,
    required this.sysIconPath,
    required this.backgroundPath,
    required this.selfIconPath,
  });
  
  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      id: json['id'],
      sysIconPath: json['sysIconPath'],
      backgroundPath: json['backgroundPath'],
      selfIconPath: json['selfIconPath'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sysIconPath': sysIconPath,
      'backgroundPath': backgroundPath,
      'selfIconPath': selfIconPath,
    };
  }
  
  UserConfig copyWith({
    String? id,
    String? sysIconPath,
    String? backgroundPath,
    String? selfIconPath,
  }) {
    return UserConfig(
      id: id ?? this.id,
      sysIconPath: sysIconPath ?? this.sysIconPath,
      backgroundPath: backgroundPath ?? this.backgroundPath,
      selfIconPath: selfIconPath ?? this.selfIconPath,
    );
  }

}

