import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:acepick/features/race/data/models/race_model.dart';

/// 로컬 알림 서비스
/// 
/// Singleton 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용합니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  static NotificationService get instance => _instance;

  /// 알림 서비스 초기화
  /// 
  /// 앱 시작 시 한 번만 호출되어야 합니다.
  Future<void> initialize() async {
    try {

      // Android 설정
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 설정
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 전체 초기화 설정
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      print('✅ NotificationService 초기화 완료');
    } catch (e) {
      print('❌ NotificationService 초기화 실패: $e');
    }
  }

  /// 알림 응답 처리
  static void _onNotificationResponse(NotificationResponse response) {
    print('알림 클릭됨: ${response.payload}');
    // 여기에 알림 클릭 시 처리 로직을 추가할 수 있습니다.
  }

  /// 경주 알림 예약
  /// 
  /// 경주 시작 30분 전에 알림을 발송합니다.
  /// 
  /// [race]: 알림을 예약할 경주 정보
  Future<void> scheduleRaceReminder(RaceModel race) async {
    try {
      // 경주 시작 시간을 DateTime으로 변환
      // 실제로는 race 모델에 시간 정보가 있어야 합니다.
      // 여기서는 예시로 현재 시간 + 30분으로 설정합니다.
      final now = DateTime.now();
      final scheduledDateTime = now.add(const Duration(minutes: 30));
      final scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

      // 경주의 AI 예측 1위 말 이름 가져오기
      final topHorse = race.horses.isNotEmpty ? race.horses[0].horseName : '예측 말';

      // Android 알림 세부 설정
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'race_reminder_channel',
        'Race Reminders',
        channelDescription: 'Notifications for upcoming races',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // iOS 알림 세부 설정
      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // 전체 알림 세부 설정
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 알림 예약
      await _notificationsPlugin.zonedSchedule(
        race.raceId.hashCode, // 고유한 알림 ID
        '곧 ${race.track} ${race.raceNumber}경주 시작',
        'AI 예측 1위: $topHorse',
        scheduledTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'race_${race.raceId}',
      );

      print('✅ 경주 알림 예약 완료: ${race.track} ${race.raceNumber}경주 (예정 시간: $scheduledDateTime)');
    } catch (e) {
      print('❌ 경주 알림 예약 실패: $e');
    }
  }

  /// 테스트 알림 발송
  /// 
  /// 개발 및 테스트 목적으로 사용합니다.
  Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        0,
        '테스트 알림',
        'AcePick 로컬 알림 테스트입니다.',
        notificationDetails,
        payload: 'test_notification',
      );

      print('✅ 테스트 알림 발송 완료');
    } catch (e) {
      print('❌ 테스트 알림 발송 실패: $e');
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('✅ 모든 알림 취소 완료');
    } catch (e) {
      print('❌ 알림 취소 실패: $e');
    }
  }

  /// 특정 알림 취소
  /// 
  /// [id]: 취소할 알림의 ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('✅ 알림 취소 완료: ID $id');
    } catch (e) {
      print('❌ 알림 취소 실패: $e');
    }
  }
}
