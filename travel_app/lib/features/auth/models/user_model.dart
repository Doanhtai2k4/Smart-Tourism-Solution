class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? profilePic;
  final bool isAuthenticated;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? country;
  final String? occupation;
  final List<String>? hobbies;
  final List<String>? favorites;
  final String? phoneNumber;
  final String? bio;
  final DateTime? createdAt;
  final int? cluster;
  final String? clusterName;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.profilePic,
    required this.isAuthenticated,
    this.dateOfBirth,
    this.gender,
    this.country,
    this.occupation,
    this.hobbies,
    this.favorites,
    this.phoneNumber,
    this.bio,
    this.createdAt,
    this.cluster,
    this.clusterName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'isAuthenticated': isAuthenticated,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country,
      'occupation': occupation,
      'hobbies': hobbies,
      'favorites': favorites,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'createdAt': createdAt,
      'cluster': cluster,
      'cluster_name': clusterName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      profilePic: map['profilePic'] as String?,
      isAuthenticated: map['isAuthenticated'] as bool,
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as dynamic).toDate()
          : null,
      gender: map['gender'] as String?,
      country: map['country'] as String?,
      occupation: map['occupation'] as String?,
      hobbies: map['hobbies'] != null
          ? List<String>.from(map['hobbies'])
          : null,
      favorites: map['favorites'] != null
          ? List<String>.from(map['favorites'])
          : [],
      phoneNumber: map['phoneNumber'] as String?,
      bio: map['bio'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      cluster: map['cluster'] as int?,
      clusterName: map['cluster_name'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, name: $name, isAuthenticated: $isAuthenticated, cluster: $cluster, clusterName: $clusterName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profilePic,
    bool? isAuthenticated,
    DateTime? dateOfBirth,
    String? gender,
    String? country,
    String? occupation,
    List<String>? hobbies,
    List<String>? favorites,
    String? phoneNumber,
    String? bio,
    DateTime? createdAt,
    int? cluster,
    String? clusterName,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      occupation: occupation ?? this.occupation,
      hobbies: hobbies ?? this.hobbies,
      favorites: favorites ?? this.favorites,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      cluster: cluster ?? this.cluster,
      clusterName: clusterName ?? this.clusterName,
    );
  }
}
