import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'mongo_service.dart';
import '../providers/user_provider.dart';

class SyncService {
  final DatabaseService _dbService;
  final MongoService _mongoService;
  final UserProvider _userProvider;
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncService(this._dbService, this._mongoService, this._userProvider);

  void initialize() {
    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
        // results is a List<ConnectivityResult> in newer versions
        if (results.contains(ConnectivityResult.mobile) || 
            results.contains(ConnectivityResult.wifi)) {
          _syncPendingScans();
        }
    });

    // Also try to sync on startup
    _syncPendingScans();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> triggerSync() async {
    await _syncPendingScans();
  }

  Future<void> _syncPendingScans() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return; // Offline

    final userId = _userProvider.uid.isNotEmpty ? _userProvider.uid : _userProvider.email;
    
    // If we don't have a valid user ID, we can't sync to the correct user.
    if (userId.isEmpty || userId == 'andrew.ainsley@yourdomain.com') return;

    debugPrint("SyncService: Starting sync for user $userId...");

    try {
      final unsynced = await _dbService.getUnsyncedScans();
      if (unsynced.isEmpty) {
        debugPrint("SyncService: No pending items.");
        return;
      }

      int syncedCount = 0;
      for (final scan in unsynced) {
        try {
          // Send to Backend
          await _mongoService.saveScanResult({
            'userId': userId,
            'diseaseName': scan['diseaseName'],
            'confidence': scan['confidence'],
            'imagePath': scan['imagePath'], // Note: Still local path. 
            'date': scan['date'],
            'notes': 'Synced from offline',
          });

          // Mark as Synced locally
          await _dbService.markAsSynced(scan['id']);
          syncedCount++;
        } catch (e) {
          debugPrint("SyncService: Failed to sync item ${scan['id']}: $e");
        }
      }
      debugPrint("SyncService: Synced $syncedCount items.");
    } catch (e) {
      debugPrint("SyncService: Error during sync: $e");
    }
  }
}
