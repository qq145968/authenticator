class Account {
  final int? id;
  final String issuer;
  final String label;
  final String secret;
  final String algorithm;
  final int digits;
  final int period;
  final String category;
  final String? iconUrl;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  Account({
    this.id,
    required this.issuer,
    required this.label,
    required this.secret,
    this.algorithm = 'SHA1',
    this.digits = 6,
    this.period = 30,
    this.category = '未分类',
    this.iconUrl,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issuer': issuer,
      'label': label,
      'secret': secret,
      'algorithm': algorithm,
      'digits': digits,
      'period': period,
      'category': category,
      'icon_url': iconUrl,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      issuer: map['issuer'] as String,
      label: map['label'] as String,
      secret: map['secret'] as String,
      algorithm: map['algorithm'] as String? ?? 'SHA1',
      digits: map['digits'] as int? ?? 6,
      period: map['period'] as int? ?? 30,
      category: map['category'] as String? ?? '未分类',
      iconUrl: map['icon_url'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deleted_at'] as int)
          : null,
    );
  }

  Account copyWith({
    int? id,
    String? issuer,
    String? label,
    String? secret,
    String? algorithm,
    int? digits,
    int? period,
    String? category,
    String? iconUrl,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Account(
      id: id ?? this.id,
      issuer: issuer ?? this.issuer,
      label: label ?? this.label,
      secret: secret ?? this.secret,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
