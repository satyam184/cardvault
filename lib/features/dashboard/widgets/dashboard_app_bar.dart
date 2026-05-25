import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';

class DashboardAppBar extends StatelessWidget {
  final double horizontalPadding;

  const DashboardAppBar({super.key, required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          20,
          horizontalPadding,
          20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  'CardVault',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  onPressed: () {
                    context.read<AuthBloc>().add(LoggedOut());
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white70,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
