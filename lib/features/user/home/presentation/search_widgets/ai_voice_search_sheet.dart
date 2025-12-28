import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AiVoiceSearchSheet extends StatefulWidget {
  const AiVoiceSearchSheet({super.key});

  @override
  State<AiVoiceSearchSheet> createState() => _AiVoiceSearchSheetState();
}

class _AiVoiceSearchSheetState extends State<AiVoiceSearchSheet> {
  final _record = AudioRecorder();

  bool _isRecording = false;
  bool _busy = false;
  String? _error;

  String? _path;

  @override
  void dispose() {
    _safeStop();
    _record.dispose();
    super.dispose();
  }

  Future<void> _safeStop() async {
    try {
      if (await _record.isRecording()) {
        await _record.stop();
      }
    } catch (_) {}
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final ok = await _record.hasPermission();
      if (!ok) {
        setState(() {
          _error = 'الرجاء السماح بصلاحية المايك.';
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${dir.path}/$fileName';

      _path = path;

      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // m4a
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 64000,
        ),
        path: path,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      setState(() => _error = 'تعذر بدء التسجيل.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopAndReturn() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final outPath = await _record.stop();
      setState(() => _isRecording = false);

      final finalPath = outPath ?? _path;
      if (finalPath == null) {
        setState(() => _error = 'تعذر حفظ التسجيل.');
        return;
      }

      final f = File(finalPath);
      if (!await f.exists()) {
        setState(() => _error = 'ملف التسجيل غير موجود.');
        return;
      }

      if (!mounted) return;
      Navigator.pop(context, f);
    } catch (_) {
      setState(() => _error = 'تعذر إنهاء التسجيل.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: SizeConfig.padding(all: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeConfig.radius(18)),
          ),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.6),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: SizeConfig.h(14)),
              Text(
                'بحث بالصوت',
                style: TextStyle(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: SizeConfig.h(6)),
              Text(
                'اضغطي تسجيل، احكي مشكلتك، بعدين إيقاف.',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: SizeConfig.h(14)),

              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.borderLight.withValues(alpha: 0.9),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: SizeConfig.ts(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy
                          ? null
                          : (_isRecording ? _stopAndReturn : _start),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording
                            ? Colors.redAccent
                            : AppColors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isRecording ? 'إيقاف وإرسال' : 'تسجيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: SizeConfig.ts(14),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(8)),
            ],
          ),
        ),
      ),
    );
  }
}
