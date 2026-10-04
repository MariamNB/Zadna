import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/kitchen_theme.dart';
import '../../data/models/household.dart';
import '../../providers.dart';

class HouseholdScreen extends ConsumerStatefulWidget {
  const HouseholdScreen({super.key});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  List<HouseholdSummary> _households = [];
  List<HouseholdMember> _members = [];
  List<HouseholdInvitation> _incoming = [];
  List<HouseholdInvitation> _sent = [];
  HouseholdSummary? _current;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _message(Object error) {
    if (error is DioException && error.response?.data is Map) {
      final detail = error.response!.data['detail'];
      if (detail is String) return detail;
      if (error.response?.statusCode == 422)
        return 'Please enter a valid email or name.';
    }
    return 'Could not complete this request. Please try again.';
  }

  Future<void> _load() async {
    try {
      final repository = ref.read(householdRepositoryProvider);
      final households = await repository.listHouseholds();
      if (!mounted) return;
      final auth = ref.read(authNotifierProvider);
      if (auth is! Authenticated || households.isEmpty) {
        throw StateError('No active household');
      }
      final selected = households.firstWhere(
        (h) => h.id == auth.householdId,
        orElse: () => households.first,
      );
      if (selected.id != auth.householdId) {
        await ref
            .read(authNotifierProvider.notifier)
            .selectHousehold(selected.id);
        if (!mounted) return;
        _clearHouseholdData();
      }
      final results = await Future.wait([
        repository.listMembers(),
        repository.listInvitations(incoming: true),
        selected.canManage
            ? repository.listInvitations()
            : Future.value(<HouseholdInvitation>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _households = households;
        _current = selected;
        _members = results[0] as List<HouseholdMember>;
        _incoming = results[1] as List<HouseholdInvitation>;
        _sent = results[2] as List<HouseholdInvitation>;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = _message(e);
        });
    }
  }

  void _clearHouseholdData() {
    ref.invalidate(inventoryNotifierProvider);
    ref.invalidate(storageNotifierProvider);
    ref.invalidate(activeHouseholdProvider);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        await _load();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message(e))),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switch(String id) async {
    await _run(() async {
      await ref.read(authNotifierProvider.notifier).selectHousehold(id);
      if (!mounted) return;
      _clearHouseholdData();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    });
  }

  Future<void> _edit({bool invite = false}) async {
    var text = invite ? '' : _current!.name;
    final form = GlobalKey<FormState>();
    var role = 'member';
    final result = await showDialog<({String text, String role})>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
                title: Text(
                    invite ? 'Invite a household member' : 'Rename household'),
                content: Form(
                  key: form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      initialValue: text,
                      onChanged: (value) => text = value,
                      autofocus: true,
                      maxLength: invite ? 255 : 100,
                      keyboardType: invite
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      decoration: InputDecoration(
                          labelText:
                              invite ? 'Email address' : 'Household name'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty)
                          return invite
                              ? 'Enter an email address'
                              : 'Enter a name';
                        if (invite &&
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(text)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    if (invite && _current!.role == 'owner')
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(
                              value: 'member', child: Text('Member')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => role = value!),
                      ),
                    if (invite)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                            'The invitation will appear in their Household screen when they sign in with this email. It expires in 7 days.'),
                      ),
                  ]),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(context, (text: text.trim(), role: role));
                      }
                    },
                    child: Text(invite ? 'Invite' : 'Save'),
                  ),
                ],
              )),
    );
    if (!mounted) return;
    if (result != null) {
      await _run(() async {
        final repository = ref.read(householdRepositoryProvider);
        if (invite) {
          await repository.invite(result.text, result.role);
        } else {
          await repository.rename(result.text);
          ref.invalidate(activeHouseholdProvider);
        }
      });
    }
  }

  Future<void> _remove(HouseholdMember member, {bool leave = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(leave ? 'Leave this household?' : 'Remove ${member.email}?'),
        content: const Text(
            'Household access will end. Existing items, locations, and activity history will be kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(leave ? 'Leave' : 'Remove')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await ref.read(householdRepositoryProvider).remove(member.id);
      if (leave && mounted) {
        final remaining =
            await ref.read(householdRepositoryProvider).listHouseholds();
        if (!mounted) return;
        await ref
            .read(authNotifierProvider.notifier)
            .selectHousehold(remaining.first.id);
        if (!mounted) return;
        _clearHouseholdData();
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    });
  }

  Widget _section(String title, List<Widget> children) => Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: KT.poppins(size: 17, weight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Household'), actions: [
        IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh)),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Try again')),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_busy) const LinearProgressIndicator(),
                      _section('Your households', [
                        Text(
                            'Switch to view a household’s shared inventory and locations.',
                            style: KT.poppins(size: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        for (final household in _households)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                                household.id == _current!.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: KT.kGreen),
                            title: Text(household.name),
                            subtitle: Text(
                                '${household.role}${household.id == _current!.id ? ' · Active' : ''}'),
                            onTap: _busy || household.id == _current!.id
                                ? null
                                : () => _switch(household.id),
                          ),
                        if (_current!.canManage)
                          TextButton.icon(
                              onPressed: _busy ? null : _edit,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Rename active household')),
                      ]),
                      _section('Invitations for you', [
                        if (_incoming.isEmpty)
                          const Text('No pending invitations'),
                        for (final invitation in _incoming)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(invitation.householdName,
                                      style:
                                          KT.poppins(weight: FontWeight.w600)),
                                  Text('Join as ${invitation.role}'),
                                  Wrap(spacing: 8, children: [
                                    FilledButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _run(() => ref
                                                .read(
                                                    householdRepositoryProvider)
                                                .respond(invitation.id,
                                                    accept: true)),
                                        child: const Text('Accept')),
                                    TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _run(() => ref
                                                .read(
                                                    householdRepositoryProvider)
                                                .respond(invitation.id,
                                                    accept: false)),
                                        child: const Text('Decline')),
                                  ]),
                                ]),
                          ),
                      ]),
                      _section('Members · ${_members.length}', [
                        for (final member in _members)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person_outline),
                            title: Text(member.email,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                '${member.role}${auth is Authenticated && member.userId == auth.userId ? ' · You' : ''}'),
                            trailing: member.role == 'owner' ||
                                    member.id == _current!.memberId ||
                                    !_current!.canManage ||
                                    (_current!.role == 'admin' &&
                                        member.role != 'member')
                                ? null
                                : PopupMenuButton<String>(
                                    enabled: !_busy,
                                    onSelected: (action) {
                                      if (action == 'remove') {
                                        _remove(member);
                                      } else {
                                        _run(() => ref
                                            .read(householdRepositoryProvider)
                                            .changeRole(member.id, action));
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      if (_current!.role == 'owner')
                                        PopupMenuItem(
                                            value: member.role == 'admin'
                                                ? 'member'
                                                : 'admin',
                                            child: Text(member.role == 'admin'
                                                ? 'Make member'
                                                : 'Make admin')),
                                      const PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Remove member')),
                                    ],
                                  ),
                          ),
                        if (_current!.canManage)
                          FilledButton.icon(
                              onPressed:
                                  _busy ? null : () => _edit(invite: true),
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text('Invite member')),
                        if (_current!.role != 'owner')
                          TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _remove(
                                      _members.firstWhere(
                                          (m) => m.id == _current!.memberId),
                                      leave: true),
                              child: const Text('Leave household')),
                      ]),
                      if (_current!.canManage)
                        _section('Pending invitations', [
                          if (_sent.isEmpty)
                            const Text('No pending invitations'),
                          for (final invitation in _sent)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(invitation.email),
                              subtitle: Text(invitation.role),
                              trailing: _current!.role != 'owner' &&
                                      invitation.role == 'admin'
                                  ? null
                                  : IconButton(
                                      tooltip: 'Cancel invitation',
                                      onPressed: _busy
                                          ? null
                                          : () => _run(() => ref
                                              .read(householdRepositoryProvider)
                                              .revoke(invitation.id)),
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                        ]),
                    ],
                  ),
                ),
    );
  }
}
