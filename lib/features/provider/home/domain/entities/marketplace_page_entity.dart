import 'marketplace_request_entity.dart';

class MarketplacePagedResult {
  final List<MarketplaceRequestEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const MarketplacePagedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}
