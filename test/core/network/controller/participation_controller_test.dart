import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/network/repository/participation_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockParticipationRepository extends Mock
    implements ParticipationRepository {}

class _TestParticipationController extends ParticipationController {
  @override
  Future<List<ParticipationInfo>> build() => buildImpl();
}

void main() {
  setUpAll(() {
    registerFallbackValue((ParticipationInfo value) => value.eventId);
  });

  test('reloads participations when the signed-in repository changes',
      () async {
    final _MockParticipationRepository signedOutRepository =
        _MockParticipationRepository();
    final _MockParticipationRepository signedInRepository =
        _MockParticipationRepository();
    const ParticipationInfo linkedEvent = ParticipationInfo(
      eventId: 'linked-event',
      participationType: ParticipationType.onSite,
    );

    when(() => signedOutRepository.getLatest(getId: any(named: 'getId')))
        .thenAnswer((_) async => <ParticipationInfo>[]);
    when(() => signedInRepository.getLatest(getId: any(named: 'getId')))
        .thenAnswer((_) async => <ParticipationInfo>[linkedEvent]);

    final StateProvider<bool> signedInProvider =
        StateProvider<bool>((Ref ref) => false);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        participationRepositoryProvider.overrideWith(
          (Ref ref) => ref.watch(signedInProvider)
              ? signedInRepository
              : signedOutRepository,
        ),
        participationControllerProvider.overrideWith(
          _TestParticipationController.new,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(participationControllerProvider.future),
      isEmpty,
    );

    container.read(signedInProvider.notifier).state = true;

    expect(
      await container.read(participationControllerProvider.future),
      <ParticipationInfo>[linkedEvent],
    );
    verify(() => signedOutRepository.getLatest(getId: any(named: 'getId')))
        .called(1);
    verify(() => signedInRepository.getLatest(getId: any(named: 'getId')))
        .called(1);
  });
}
