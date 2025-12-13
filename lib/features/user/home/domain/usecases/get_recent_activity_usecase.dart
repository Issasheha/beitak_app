// get_recent_activity_usecase.dart
import '../entities/recent_activity_entity.dart';
import '../repositories/profile_repository.dart';

class GetRecentActivityUseCase {
  final ProfileRepository repo;
  const GetRecentActivityUseCase(this.repo);

  Future<List<RecentActivityEntity>> call({int limit = 10}) =>
      repo.getRecentActivity(limit: limit);
}
