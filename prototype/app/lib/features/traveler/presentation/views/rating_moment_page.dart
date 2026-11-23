import 'package:flutter/material.dart';
import 'package:studio_app/features/explore/presentation/views/explore_page.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/views/wallet_page.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_notification.dart';
import 'package:studio_app/features/traveler/presentation/widgets/rating_sheet.dart';

/// Cena 8: de volta ao hotel, chega o pedido de avaliação sobre a home.
class RatingMomentPage extends StatefulWidget {
  const RatingMomentPage({super.key});

  @override
  State<RatingMomentPage> createState() => _RatingMomentPageState();
}

class _RatingMomentPageState extends State<RatingMomentPage> {
  @override
  void initState() {
    super.initState();
    travelerCubit().ensureMoment(transferDone: true);
  }

  @override
  Widget build(BuildContext context) {
    final role = TravelMock.roleById(TravelMock.swapToId);
    return Theme(
      data: travelTheme(context),
      child: Builder(
        builder: (context) => MareNotificationOverlay(
          title: 'Como foi o ${role.shortName}?',
          body: 'Dois toques ajudam outras mulheres a decidir.',
          onTap: () => showRatingSheet(
            context,
            roleId: role.id,
            roleName: role.shortName,
            photo: role.photos.first.asset,
            withTransfer: true,
            onWallet: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WalletPage())),
          ),
          child: const ExplorePage(),
        ),
      ),
    );
  }
}
