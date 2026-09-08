import 'package:den_backend/config/database.dart';
import 'package:postgres/postgres.dart';

class EventService {
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data, String organizerId) async {
    return await Database.pool.runTx((ctx) async {
      final eventId = data['id'] ?? (await ctx.execute('SELECT uuid_generate_v4()')).first[0] as String;
      
      await ctx.execute(
        Sql.named('''
          INSERT INTO events (
            id, organizer_id, title, category, description, banner_url, gallery_urls,
            event_date, start_time, end_time, venue_name, venue_address, latitude, longitude, google_maps_url,
            location_mode, venue_visibility, exclusivity, capacity, capacity_men, capacity_women, capacity_non_binary,
            gender_requirement, require_instagram, require_verification, alcohol_available, allow_cancellation,
            search_engine_visible, contact_info, pricing_type, status
          ) VALUES (
            @id, @organizerId, @title, @category, @description, @bannerUrl, @galleryUrls,
            @eventDate, @startTime, @endTime, @venueName, @venueAddress, @latitude, @longitude, @googleMapsUrl,
            @locationMode, @venueVisibility, @exclusivity, @capacity, @capacityMen, @capacityWomen, @capacityNonBinary,
            @genderRequirement, @requireInstagram, @requireVerification, @alcoholAvailable, @allowCancellation,
            @searchEngineVisible, @contactInfo, @pricingType, @status
          )
        '''),
        parameters: {
          'id': eventId,
          'organizerId': organizerId,
          'title': data['title'],
          'category': data['category'],
          'description': data['description'],
          'bannerUrl': data['bannerUrl'],
          'galleryUrls': data['galleryUrls'] != null ? data['galleryUrls'].toString() : null, // Handle JSONB properly in prod
          'eventDate': data['date'] != null ? DateTime.parse(data['date'].toString()) : null,
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'venueName': data['venueName'],
          'venueAddress': data['venueAddress'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'googleMapsUrl': data['googleMapsUrl'],
          'locationMode': data['locationMode'] ?? 'searchedAddress',
          'venueVisibility': data['venueVisibility'] ?? 'alwaysVisible',
          'exclusivity': data['exclusivity'] ?? 'approvedOnly',
          'capacity': data['capacity'],
          'capacityMen': data['capacityByGender']?['men'],
          'capacityWomen': data['capacityByGender']?['women'],
          'capacityNonBinary': data['capacityByGender']?['nonBinary'],
          'genderRequirement': data['genderRequirement'] ?? 'all',
          'requireInstagram': data['requireInstagram'] ?? false,
          'requireVerification': data['requireVerification'] ?? false,
          'alcoholAvailable': data['alcoholAvailable'] ?? true,
          'allowCancellation': data['allowCancellation'] ?? false,
          'searchEngineVisible': data['searchEngineVisible'] ?? true,
          'contactInfo': data['contactInfo'],
          'pricingType': data['pricingType'] ?? 'paid',
          'status': data['status'] ?? 'published',
        },
      );

      final ticketTiers = data['ticketTiers'] as List<dynamic>? ?? [];
      for (final tier in ticketTiers) {
        await ctx.execute(
          Sql.named('''
            INSERT INTO event_ticket_tiers (
              event_id, name, badge, note, price, is_limited, quantity_limit
            ) VALUES (
              @eventId, @name, @badge, @note, @price, @isLimited, @quantityLimit
            )
          '''),
          parameters: {
            'eventId': eventId,
            'name': tier['name'],
            'badge': tier['badge'] ?? 'SINGLE',
            'note': tier['note'],
            'price': tier['price'] ?? 0.0,
            'isLimited': tier['isLimited'] ?? false,
            'quantityLimit': tier['quantityLimit'],
          },
        );
      }

      final coupons = data['coupons'] as List<dynamic>? ?? [];
      for (final coupon in coupons) {
        await ctx.execute(
          Sql.named('''
            INSERT INTO event_coupons (
              event_id, code, discount_type, discount_value, usage_limit
            ) VALUES (
              @eventId, @code, @discountType, @discountValue, @usageLimit
            )
          '''),
          parameters: {
            'eventId': eventId,
            'code': coupon['code'],
            'discountType': coupon['type'],
            'discountValue': coupon['value'],
            'usageLimit': coupon['usageLimit'],
          },
        );
      }

      return {'id': eventId, 'status': 'success'};
    });
  }

  Future<List<Map<String, dynamic>>> getFeed({
    required double userLat,
    required double userLng,
    required double radiusKm,
  }) async {
    // 1 degree of latitude is ~111 km
    final latDelta = radiusKm / 111.0;
    // 1 degree of longitude varies by latitude, cos(lat) * 111
    // Simplification for the bounding box query:
    
    final result = await Database.pool.execute(
      Sql.named('''
        SELECT 
          id, title, event_date, start_time, venue_address, banner_url,
          capacity,
          (
            6371 * acos(
              cos(radians(@userLat)) * cos(radians(latitude)) *
              cos(radians(longitude) - radians(@userLng)) +
              sin(radians(@userLat)) * sin(radians(latitude))
            )
          ) AS distance_km
        FROM events
        WHERE status = 'published'
          AND latitude BETWEEN @minLat AND @maxLat
          AND longitude BETWEEN @minLng AND @maxLng
      '''),
      parameters: {
        'userLat': userLat,
        'userLng': userLng,
        'minLat': userLat - latDelta,
        'maxLat': userLat + latDelta,
        'minLng': userLng - (latDelta / 0.5), // rough approximation for bounds
        'maxLng': userLng + (latDelta / 0.5),
      },
    );

    final List<Map<String, dynamic>> feed = [];
    for (final row in result) {
      final distance = (row[7] as num?)?.toInt() ?? 0;
      if (distance <= radiusKm) {
        // Format dates as expected by mock_interceptor.dart e.g. "12 Oct '24"
        // This is a naive formatter. A real one might use intl.
        final date = row[2] as DateTime?;
        final dateStr = date != null ? '\${date.day} \${date.month} \\'\${date.year.toString().substring(2)}' : '';
        
        feed.add({
          'id': row[0].toString(),
          'title': row[1] as String,
          'dateStr': dateStr, // "12 Oct '24"
          'timeStr': row[3] as String?, // "9:00 PM"
          'locationStr': row[4] as String?, // venue_address shortened? We'll use full for now
          'joinedCountText': '+0', // To be aggregated
          'statsText': '0 Joined • \${row[6] ?? 'Unlimited'} Spots Left', // Mock stats
          'imageUrl': row[5] as String?,
          'distanceKm': distance,
        });
      }
    }
    
    // Sort by distance
    feed.sort((a, b) => (a['distanceKm'] as int).compareTo(b['distanceKm'] as int));
    
    return feed;
  }

  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    return await Database.pool.runTx((ctx) async {
      final eventResult = await ctx.execute(
        Sql.named('''
          SELECT e.*, u.id as org_id, u.username, u.avatar_url 
          FROM events e
          JOIN users u ON e.organizer_id = u.id
          WHERE e.id = @id
        '''),
        parameters: {'id': eventId},
      );
      
      if (eventResult.isEmpty) return null;
      
      final e = eventResult.first.toColumnMap();
      
      final ticketsResult = await ctx.execute(
        Sql.named('SELECT * FROM event_ticket_tiers WHERE event_id = @id'),
        parameters: {'id': eventId},
      );
      
      final couponsResult = await ctx.execute(
        Sql.named('SELECT * FROM event_coupons WHERE event_id = @id'),
        parameters: {'id': eventId},
      );

      final Map<String, dynamic> response = {
        'id': e['id'],
        'title': e['title'],
        'description': e['description'],
        'category': e['category'],
        'date': e['event_date']?.toString(),
        'startTime': e['start_time'],
        'endTime': e['end_time'],
        'venueName': e['venue_name'],
        'venueAddress': e['venue_address'],
        'latitude': e['latitude'],
        'longitude': e['longitude'],
        'googleMapsUrl': e['google_maps_url'],
        'bannerUrl': e['banner_url'],
        'capacity': e['capacity'],
        'pricingType': e['pricing_type'],
        'status': e['status'],
        'organizer': {
          'id': e['org_id'],
          'name': e['username'], // Using username as name
          'avatarUrl': e['avatar_url']
        },
        'ticketTiers': ticketsResult.map((t) => t.toColumnMap()).toList(),
        'coupons': couponsResult.map((c) => c.toColumnMap()).toList(),
        // Extra UI hinted fields
        'attendeeCount': 0, // Placeholder
        'attendees': [], // Placeholder preview array
      };
      
      return response;
    });
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data, String organizerId) async {
    // Only update allowed fields (title, description, status etc.)
    await Database.pool.execute(
      Sql.named('''
        UPDATE events 
        SET title = COALESCE(@title, title),
            description = COALESCE(@description, description),
            status = COALESCE(@status, status),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = @id AND organizer_id = @organizerId
      '''),
      parameters: {
        'id': eventId,
        'organizerId': organizerId,
        'title': data['title'],
        'description': data['description'],
        'status': data['status'],
      },
    );
  }

  Future<void> cancelEvent(String eventId, String organizerId) async {
    final result = await Database.pool.execute(
      Sql.named('''
        UPDATE events 
        SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
        WHERE id = @id 
          AND organizer_id = @organizerId 
          AND allow_cancellation = TRUE
        RETURNING id
      '''),
      parameters: {
        'id': eventId,
        'organizerId': organizerId,
      },
    );
    
    if (result.isEmpty) {
      throw Exception('Event cannot be cancelled or does not belong to you.');
    }
  }
}
