part of 'ledger.dart';

// shortcut: local demo tokens/actors only; production must use hashed tokens, authenticated sessions and server authorization.
extension MembershipRules on BillGroup {
  Map<String, dynamic> invitation(String token) {
    final link = invitations.where((l) => l['token'] == token).firstOrNull;
    require(
      link != null &&
          link['revoked'] != true &&
          DateTime.parse(link['expiresAt'] as String).isAfter(DateTime.now()),
      'Link hết hạn hoặc đã thu hồi.',
    );
    return link!;
  }

  String createInvite(String actor, {String? memberId}) {
    require(actor == treasurer, 'Chỉ trưởng nhóm mẫu được cấp link.');
    require(
      memberId == null || hasMember(memberId),
      'Không tìm thấy thành viên.',
    );
    final random = Random.secure();
    final token = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    invitations.add({
      'token': token,
      'memberId': memberId,
      'expiresAt': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
      'revoked': false,
    });
    membershipAudit.add({
      'action': 'invite',
      'memberId': memberId,
      'actor': actor,
    });
    return token;
  }

  Member guestMember(String token) {
    final link = invitation(token);
    require(link['memberId'] != null, 'Link chung chưa cấp quyền xem.');
    return members.firstWhere((m) => m.id == link['memberId']);
  }

  void revokeInvite(String token, String actor) {
    require(actor == treasurer, 'Chỉ trưởng nhóm được thu hồi.');
    final link = invitations.where((l) => l['token'] == token).firstOrNull;
    require(link != null, 'Không tìm thấy link.');
    link!['revoked'] = true;
    membershipAudit.add({'action': 'revoke', 'actor': actor});
  }

  void _bind(String memberId, String accountId) {
    require(
      accountId.trim().isNotEmpty && accountId.length <= 80,
      'Cần tài khoản hợp lệ.',
    );
    final index = members.indexWhere((m) => m.id == memberId);
    require(index >= 0, 'Không tìm thấy hồ sơ.');
    final m = members[index];
    require(
      m.accountId == null || m.accountId == accountId,
      'Hồ sơ đã được nhận bởi tài khoản khác.',
    );
    require(
      !members.any((x) => x.id != memberId && x.accountId == accountId),
      'Tài khoản đã là thành viên; không tự gộp hồ sơ.',
    );
    members[index] = Member(m.id, m.name, accountId: accountId);
  }

  void claimProfile(String token, String accountId) {
    final m = guestMember(token);
    _bind(m.id, accountId);
    for (final l in invitations.where((l) => l['memberId'] == m.id)) {
      l['revoked'] = true;
    }
    membershipAudit.add({
      'action': 'claim',
      'memberId': m.id,
      'accountId': accountId,
    });
  }

  void requestJoin(String token, String accountId, String displayName) {
    require(
      invitation(token)['memberId'] == null,
      'Hãy nhận hồ sơ từ link riêng.',
    );
    require(
      accountId.trim().isNotEmpty && accountId.length <= 80,
      'Cần đăng nhập.',
    );
    require(
      displayName.trim().isNotEmpty && displayName.trim().length <= 50,
      'Tên cần từ 1 đến 50 ký tự.',
    );
    require(
      !members.any((m) => m.accountId == accountId),
      'Bạn đã là thành viên.',
    );
    if (joinRequests.any(
      (r) => r['accountId'] == accountId && r['status'] == 'pending',
    )) {
      return;
    }
    joinRequests.add({
      'id': newId(),
      'accountId': accountId,
      'name': displayName.trim(),
      'status': 'pending',
    });
  }

  void reviewJoin(
    String requestId,
    String actor, {
    required bool accept,
    String? memberId,
  }) {
    require(actor == treasurer, 'Chỉ trưởng nhóm được duyệt.');
    final r = joinRequests.where((r) => r['id'] == requestId).firstOrNull;
    require(r != null && r['status'] == 'pending', 'Yêu cầu đã được xử lý.');
    if (accept) {
      require(
        !members.any((m) => m.accountId == r!['accountId']),
        'Tài khoản đã thuộc nhóm.',
      );
      if (memberId != null) {
        _bind(memberId, r!['accountId'] as String);
      } else {
        require(
          members.length < 30,
          'Bản thử nghiệm hỗ trợ tối đa 30 thành viên.',
        );
        memberId = newId();
        members.add(
          Member(
            memberId,
            r!['name'] as String,
            accountId: r['accountId'] as String,
          ),
        );
      }
      r['memberId'] = memberId;
    }
    r!['status'] = accept ? 'approved' : 'rejected';
    membershipAudit.add({
      'action': r['status'],
      'requestId': requestId,
      'memberId': memberId,
      'actor': actor,
    });
  }
}
