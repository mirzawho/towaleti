import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:towaleti/models/place.model.dart';
import 'package:towaleti/shared/constants.dart';
import 'package:towaleti/shared/platform/map_cacher.dart';

class MapWidget extends StatelessWidget {
  final MapController controller;
  final Function? onReady;
  final void Function({required LatLng location, required double zoom})?
      onPositionChange;
  final LatLng? currentPosition;
  final List<PlaceModel> places;
  final void Function({required PlaceModel place})? onPlaceSelect;

  MapWidget({
    super.key,
    required this.controller,
    this.onReady,
    this.onPositionChange,
    this.currentPosition,
    this.places = const [],
    this.onPlaceSelect,
  });

  Timer? positionChangeTimer;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCacheStore(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final cacheStore = snapshot.data!;
          return FlutterMap(
            mapController: controller,
            options: MapOptions(
              initialCenter: LatLng(32.4207423, 53.6830157),
              initialZoom: 5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              onMapReady: () {
                if (onReady != null) {
                  onReady!();
                }
              },
              onPositionChanged: (position, hasGesture) {
                if (onPositionChange != null) {
                  if (positionChangeTimer != null) {
                    positionChangeTimer!.cancel();
                  }

                  positionChangeTimer = Timer(
                    Duration(milliseconds: 500),
                    () {
                      onPositionChange!(
                        location: position.center,
                        zoom: position.zoom,
                      );
                    },
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: CONSTANTS.urlMap,
                // disable rotation
                tileProvider: kIsWeb
                    ? null
                    : CachedTileProvider(
                        // use the store for your CachedTileProvider instance
                        store: cacheStore,
                      ),
              ),
              MarkerLayer(
                markers: [
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 20,
                      height: 20,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.quaternarySystemFill,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: CupertinoColors.white,
                            width: 2,
                          ),
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (var item in places)
                    Marker(
                      point: LatLng(item.lat, item.lon),
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        onTap: () {
                          if (onPlaceSelect != null) {
                            onPlaceSelect!(place: item);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.quaternarySystemFill,
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xfffde68a),
                                Color(0xfffbbf24),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.map_pin,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}
