import 'package:semesta_gym/models/membership.dart';

class MembershipByUserId {
  final int id;
  final int userId;
  final int membershipId;
  final String startDate;
  final String endDate;
  final Membership membership;

  MembershipByUserId({
    required this.id,
    required this.userId,
    required this.membershipId,
    required this.startDate,
    required this.endDate,
    required this.membership,
  });

  factory MembershipByUserId.fromJson(Map<String, dynamic> json) {
    return MembershipByUserId(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      membershipId: json['membershipId'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      membership: Membership.fromJson(json['Membership']),
    );
  }
}
