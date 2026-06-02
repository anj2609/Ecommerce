import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/features/location/data/datasources/location_datasource.dart';

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  return LocationDataSource();
});

class LocationState {
  final String? address;
  final bool isLoading;
  final String? error;

  const LocationState({this.address, this.isLoading = false, this.error});

  LocationState copyWith({String? address, bool? isLoading, String? error, bool clearError = false}) {
    return LocationState(
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationDataSource _dataSource;

  LocationNotifier(this._dataSource) : super(const LocationState());

  Future<void> fetchLocation() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final position = await _dataSource.getCurrentPosition();
      final address = await _dataSource.getAddressFromPosition(position);
      state = LocationState(address: address, isLoading: false);
    } on LocationException catch (e) {
      state = LocationState(error: e.message, isLoading: false);
    } catch (e) {
      state = LocationState(error: 'Failed to get location', isLoading: false);
    }
  }
}

final locationNotifierProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.watch(locationDataSourceProvider));
});
