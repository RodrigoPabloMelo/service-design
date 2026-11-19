import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';

/// Card no chat: datas e hospedagem antes do roteiro (etapa 04, D-23).
/// Chips de escolha única + um primário. Respondido, some (a resposta
/// vira a bolha dela).
class TripInfoCard extends StatefulWidget {
  const TripInfoCard({required this.onSubmit, super.key});

  final void Function(String dates, String stayId) onSubmit;

  @override
  State<TripInfoCard> createState() => _TripInfoCardState();
}

class _TripInfoCardState extends State<TripInfoCard> {
  String _dates = TravelerMock.defaultDates;
  String? _stay;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.trip != b.trip,
      builder: (context, s) {
        if (s.trip != null) return const SizedBox.shrink();
        return SolidBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datas',
                  style: TravelType.section.copyWith(color: p.inkMuted)),
              const SizedBox(height: TravelSpace.sm),
              Wrap(
                spacing: TravelSpace.sm,
                runSpacing: TravelSpace.sm,
                children: [
                  for (final d in TravelerMock.dateOptions)
                    ExploreChip(
                      label: d,
                      selected: d == _dates,
                      onTap: () => setState(() => _dates = d),
                    ),
                ],
              ),
              const SizedBox(height: TravelSpace.lg),
              Text('Onde vai ficar',
                  style: TravelType.section.copyWith(color: p.inkMuted)),
              const SizedBox(height: TravelSpace.sm),
              Wrap(
                spacing: TravelSpace.sm,
                runSpacing: TravelSpace.sm,
                children: [
                  for (final stay in TravelerMock.stays)
                    ExploreChip(
                      label: stay.name,
                      selected: stay.id == _stay,
                      onTap: () => setState(() => _stay = stay.id),
                    ),
                ],
              ),
              const SizedBox(height: TravelSpace.lg),
              // Ação única dentro de card = secundário (regra 5).
              SecondaryButton(
                label: 'Montar roteiro',
                onPressed: _stay == null
                    ? null
                    : () => widget.onSubmit(_dates, _stay!),
              ),
            ],
          ),
        );
      },
    );
  }
}
