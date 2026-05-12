import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_users_provider.dart';
import '../services/admin_users_service.dart';
import '../theme/app_colors.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = 'All';

  static const _roles = <String>[
    'All',
    'student',
    'lecturer',
    'admin',
    'judge',
    'lawyer',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminUsersProvider()..load(),
      child: Builder(
        builder: (context) {
          final provider = context.watch<AdminUsersProvider>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Users'),
              backgroundColor: AppColors.brandDark,
            ),
            backgroundColor: AppColors.brandWhite,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (value) =>
                                    context.read<AdminUsersProvider>().setSearch(value),
                                decoration: InputDecoration(
                                  hintText: 'Search by name or email',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => context
                                  .read<AdminUsersProvider>()
                                  .setSearch(_searchController.text),
                              icon: const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  isDense: true,
                                ),
                                items: _roles
                                    .map(
                                      (role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;
                                  setState(() => _selectedRole = value);
                                  await context.read<AdminUsersProvider>().setRole(
                                    value == 'All' ? null : value,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${provider.totalItems} total',
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _UsersBody(provider: provider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody({required this.provider});

  final AdminUsersProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.brandDanger),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AdminUsersProvider>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<AdminUsersProvider>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _UserTile(user: provider.users[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${provider.currentPage} of ${provider.totalPages}',
                style: const TextStyle(color: AppColors.mutedText),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: provider.currentPage <= 1
                        ? null
                        : () => context.read<AdminUsersProvider>().load(
                          page: provider.currentPage - 1,
                        ),
                    child: const Text('Prev'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: provider.currentPage >= provider.totalPages
                        ? null
                        : () => context.read<AdminUsersProvider>().load(
                          page: provider.currentPage + 1,
                        ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    final initials = user.fullName.trim().isNotEmpty
        ? user.fullName.trim()[0].toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.brandDark,
            child: Text(
              initials,
              style: const TextStyle(color: AppColors.brandWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandDark.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role.isEmpty ? 'user' : user.role,
              style: const TextStyle(
                color: AppColors.brandDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
