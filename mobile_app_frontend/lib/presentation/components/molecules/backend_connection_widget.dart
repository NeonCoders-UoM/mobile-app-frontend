import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';

class BackendConnectionWidget extends StatefulWidget {
  const BackendConnectionWidget({Key? key}) : super(key: key);

  @override
  _BackendConnectionWidgetState createState() =>
      _BackendConnectionWidgetState();
}

class _BackendConnectionWidgetState extends State<BackendConnectionWidget> {
  bool? _isConnected;
  bool _isLoading = false;
  final ServiceHistoryRepository _repository = ServiceHistoryRepository();

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isConnected = await _repository.testConnection();
      setState(() {
        _isConnected = isConnected;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (_isLoading)
            const SizedBox(
              width: 16.0,
              height: 16.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.primary200,
              ),
            )
          else
            Icon(
              _isConnected == true
                  ? Icons.cloud_done
                  : _isConnected == false
                      ? Icons.cloud_off
                      : Icons.cloud_queue,
              color: _isConnected == true
                  ? AppColors.states['ok']
                  : _isConnected == false
                      ? AppColors.states['error']
                      : AppColors.neutral200,
              size: 16.0,
            ),
          const SizedBox(width: 8.0),
          Text(
            _isLoading
                ? 'Testing connection...'
                : _isConnected == true
                    ? 'Backend connected'
                    : _isConnected == false
                        ? 'Backend offline'
                        : 'Unknown status',
            style: AppTextStyles.textXsmRegular.copyWith(
              color: _isConnected == true
                  ? AppColors.states['ok']
                  : _isConnected == false
                      ? AppColors.states['error']
                      : AppColors.neutral200,
            ),
          ),
          if (!_isLoading) ...[
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: _testConnection,
              child: Icon(
                Icons.refresh,
                size: 16.0,
                color: AppColors.neutral200,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
