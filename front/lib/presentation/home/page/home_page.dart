import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/create_room_button.dart';
import '../widgets/display_name_field.dart';
import '../widgets/home_api_hint.dart';
import '../widgets/home_error_banner.dart';
import '../widgets/home_title.dart';
import '../../shared/widgets/instructions_launch_button.dart';
import '../widgets/join_room_button.dart';
import '../widgets/room_code_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final initialCode = context.read<HomeBloc>().state.roomCode;
    _nameController = TextEditingController();
    _codeController = TextEditingController(text: initialCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == HomeStatus.success && state.session != null) {
          Navigator.of(context).pushNamed(AppRoutes.lobby);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appTitle)),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final loading = state.status == HomeStatus.loading;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HomeTitle(),
                      const SizedBox(height: 12),
                      const Center(
                          child: InstructionsLaunchButton(compact: true)),
                      const SizedBox(height: 24),
                      DisplayNameField(
                        controller: _nameController,
                        enabled: !loading,
                        onChanged: (value) {
                          context
                              .read<HomeBloc>()
                              .add(HomeDisplayNameChanged(value));
                        },
                      ),
                      const SizedBox(height: 16),
                      CreateRoomButton(
                        enabled: state.canSubmit,
                        loading: loading,
                        onPressed: () {
                          context.read<HomeBloc>().add(
                                HomeDisplayNameChanged(_nameController.text),
                              );
                          context
                              .read<HomeBloc>()
                              .add(const HomeCreateRoomRequested());
                        },
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      RoomCodeField(
                        controller: _codeController,
                        enabled: !loading,
                        onChanged: (value) {
                          context
                              .read<HomeBloc>()
                              .add(HomeRoomCodeChanged(value));
                        },
                      ),
                      const SizedBox(height: 16),
                      JoinRoomButton(
                        enabled: state.canJoin,
                        loading: loading,
                        onPressed: () {
                          context.read<HomeBloc>().add(
                                HomeDisplayNameChanged(_nameController.text),
                              );
                          context
                              .read<HomeBloc>()
                              .add(const HomeJoinRoomRequested());
                        },
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        HomeErrorBanner(message: state.errorMessage!),
                      ],
                      const SizedBox(height: 24),
                      const HomeApiHint(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
