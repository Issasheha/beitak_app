import 'package:beitak_app/features/provider/home/presentation/views/marketplace/domain/entities/marketplace_page_entity.dart';

import '../../domain/repositories/marketplace_repository.dart';
import '../../models/marketplace_filters.dart';
import '../marketplace_remote_data_source.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remote;

  MarketplaceRepositoryImpl({required this.remote});

  @override
  Future<MarketplacePagedResult> getMarketplaceRequests({
    required int page,
    required int limit,
    required MarketplaceFilters filters,
  }) {
    return remote.getMarketplaceRequests(page: page, limit: limit, filters: filters);
  }

  @override
  Future<void> acceptRequest(int requestId) {
    return remote.acceptRequest(requestId);
  }
}
