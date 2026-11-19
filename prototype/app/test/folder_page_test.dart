import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/views/folder_page.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';

/// Pasta da viagem (D-28): dias como seções, rolês sem dia em grade, e o
/// modo Organizar move os escolhidos pra um dia.
void main() {
  testWidgets('organizar à mão move o rolê pra um dia', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = travelerCubit()
      ..signIn(AccountProvider.google)
      ..setTrip(TravelerMock.trip)
      ..saveTo(SavedFolder.tripId, 'casa-astral')
      ..saveTo(SavedFolder.tripId, 'parraxaxa-casa-forte');

    await tester.pumpWidget(MaterialApp(
      home: FolderPage(folderId: SavedFolder.tripId, onOrganize: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Recife, 14 a 16 nov'), findsWidgets);
    expect(find.text('Sábado, 15 nov'), findsOneWidget);
    expect(find.text('Sem dia'), findsOneWidget);

    await tester.tap(find.text('Organizar'));
    await tester.pump(const Duration(milliseconds: 300));
    final astral = ExploreMock.roleById('casa-astral').shortName;
    await tester.tap(find.text(astral));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Mover pra um dia'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.text('Mover pra'), findsOneWidget);
    await tester.tap(find.text('Sábado, 15 nov').last);
    await tester.pump(const Duration(milliseconds: 600));

    final folder = cubit.state.folderById(SavedFolder.tripId);
    expect(folder.days.firstWhere((d) => d.id == 'd15').roleIds,
        ['casa-astral']);
    expect(folder.unsorted, ['parraxaxa-casa-forte']);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('alterna grade e lista larga com custo e quem indicou',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = travelerCubit()..signIn(AccountProvider.google);
    final id = cubit.createFolder('Olinda, dez');
    cubit.saveTo(id, 'casa-astral');
    final role = ExploreMock.roleById('casa-astral');

    await tester.pumpWidget(MaterialApp(
      home: FolderPage(folderId: id, onOrganize: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(role.cost), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ver em lista'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(role.cost), findsOneWidget);
    expect(find.text('Indicado por ${role.recommender.name}'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Ver em grade'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(role.cost), findsNothing);
  });
}
