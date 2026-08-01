import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFlowState {
  final String countryCode;
  final String phone;
  final bool otpSent;
  final String otpCode;
  final bool isSubmitting;
  final int timerSeconds;
  final String? error;

  const AuthFlowState({
    this.countryCode = '+91',
    this.phone = '',
    this.otpSent = false,
    this.otpCode = '',
    this.isSubmitting = false,
    this.timerSeconds = 30,
    this.error,
  });

  String get fullPhoneNumber => '$countryCode${phone.replaceAll(RegExp(r'\D'), '')}';

  AuthFlowState copyWith({
    String? countryCode,
    String? phone,
    bool? otpSent,
    String? otpCode,
    bool? isSubmitting,
    int? timerSeconds,
    String? error,
  }) {
    return AuthFlowState(
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      otpSent: otpSent ?? this.otpSent,
      otpCode: otpCode ?? this.otpCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      error: error,
    );
  }
}

class AuthFlowNotifier extends Notifier<AuthFlowState> {
  Timer? _timer;

  @override
  AuthFlowState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const AuthFlowState();
  }

  void setCountryCode(String code) {
    state = state.copyWith(countryCode: code, error: null);
  }

  void setPhone(String phone) {
    state = state.copyWith(phone: phone, error: null);
  }

  void setOtpCode(String code) {
    if (code.length <= 6) {
      state = state.copyWith(otpCode: code, error: null);
    }
  }

  void resetOtp() {
    _timer?.cancel();
    state = state.copyWith(otpSent: false, otpCode: '', error: null);
  }

  Future<bool> sendOtp() async {
    final digits = state.phone.replaceAll(RegExp(r'\D'), '');
    if (state.countryCode == '+91') {
      if (digits.length != 10) {
        state = state.copyWith(error: 'Please enter a valid 10-digit mobile number.');
        return false;
      }
    } else {
      if (digits.length < 7 || digits.length > 15) {
        state = state.copyWith(error: 'Please enter a valid phone number.');
        return false;
      }
    }

    state = state.copyWith(isSubmitting: true, error: null);
    
    // Simulate network delay for UI responsiveness
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(
      isSubmitting: false,
      otpSent: true,
      timerSeconds: 30,
    );

    _startTimer();
    return true;
  }

  Future<bool> verifyOtp() async {
    if (state.otpCode.length != 6) {
      state = state.copyWith(error: 'Please enter the full 6-digit code.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    // Simulate network verification delay
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(isSubmitting: false);
    return true;
  }

  void resendOtp() {
    if (state.timerSeconds > 0) return;
    state = state.copyWith(timerSeconds: 30, error: null);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds > 1) {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      } else {
        state = state.copyWith(timerSeconds: 0);
        timer.cancel();
      }
    });
  }
}

final authFlowProvider = NotifierProvider<AuthFlowNotifier, AuthFlowState>(AuthFlowNotifier.new);
