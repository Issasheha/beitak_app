import 'package:beitak_app/features/provider/home/presentation/views/marketplace/domain/entities/marketplace_page_entity.dart';

import '../models/marketplace_filters.dart';

abstract class MarketplaceRemoteDataSource {
  Future<MarketplacePagedResult> getMarketplaceRequests({
    required int page,
    required int limit,
    required MarketplaceFilters filters,
  });

  Future<void> acceptRequest(int requestId);
}
