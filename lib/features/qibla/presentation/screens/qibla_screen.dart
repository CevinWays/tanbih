import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../bloc/qibla_cubit.dart';
import '../widgets/qibla_compass.dart';

/// Which way to face.
@RoutePage()
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final location = context.read<LocationBloc>().state.location;

    return BlocProvider(
      create: (_) {
        final cubit = sl<QiblaCubit>();
        if (location != null) {
          cubit.start(
            latitude: location.latitude,
            longitude: location.longitude,
          );
        }
        return cubit;
      },
      child: const _QiblaView(),
    );
  }
}

class _QiblaView extends StatelessWidget {
  const _QiblaView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      // Full-bleed gradient: the design treats this screen as one surface
      // rather than a header over a page.
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.primaryVertical),
        child: SafeArea(
          child: BlocBuilder<QiblaCubit, QiblaState>(
            builder: (context, state) {
              return Column(
                children: [
                  Row(
                    children: [
                      const BackButton(color: Colors.white),
                      Text(l10n.qiblaTitle, style: AppTextStyle.onHeaderLabel),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: switch (state.status) {
                        QiblaStatus.success => _Dial(state: state),
                        QiblaStatus.failure => _Message(
                          text: state.failure?.message.isNotEmpty ?? false
                              ? state.failure!.message
                              : l10n.errorUnexpected,
                        ),
                        QiblaStatus.loading || QiblaStatus.initial =>
                          const CircularProgressIndicator(color: Colors.white),
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({required this.state});

  final QiblaState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bearing = state.bearing!.round();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QiblaCompass(
          headingDegrees: state.reading.headingDegrees,
          relativeBearingDegrees: state.relativeBearing,
          isFacing: state.isFacingQibla,
        ),
        const SizedBox(height: AppSpacing.xl),

        if (!state.reading.hasSensor)
          // No magnetometer: the bearing is still correct and usable with
          // any separate compass, so the screen states it plainly rather
          // than showing a dial that would never move.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: GlassCard(
              radius: AppSpacing.radiusMd,
              fill: AppColors.glassFill,
              child: Column(
                children: [
                  Text(
                    l10n.qiblaNoSensor,
                    style: AppTextStyle.onHeaderLabel,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.qiblaNoSensorBody(bearing),
                    style: AppTextStyle.onHeaderCaption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          Text(
            state.isFacingQibla ? l10n.qiblaFacing : l10n.qiblaTurn,
            style: AppTextStyle.h3.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.qiblaBearing(bearing), style: AppTextStyle.onHeaderCaption),
          if (state.reading.accuracy.needsCalibration) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                l10n.qiblaCalibrate,
                style: AppTextStyle.onHeaderCaption,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.onHeaderLabel,
      ),
    );
  }
}
