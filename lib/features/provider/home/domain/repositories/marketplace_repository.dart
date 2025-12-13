import 'package:beitak_app/features/provider/home/domain/entities/marketplace_page_entity.dart';


import '../../presentation/views/marketplace/models/marketplace_filters.dart';

abstract class MarketplaceRepository {
  Future<MarketplacePagedResult> getMarketplaceRequests({
    required int page,
    required int limit,
    required MarketplaceFilters filters,
  });

  Future<void> acceptRequest(int requestId);
}
