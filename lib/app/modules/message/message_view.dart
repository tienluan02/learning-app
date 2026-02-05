import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/chat_model.dart';
import 'package:mentor_mesh_hub/app/modules/home/components/search_field.dart';
import 'package:mentor_mesh_hub/app/modules/message/components/chat_card.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final List<ChatModel> _conversations = <ChatModel>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConversations();
    // Auto-refresh every 5 seconds
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      _loadConversations();
    }
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadConversations();
        _startAutoRefresh(); // Schedule next refresh
      }
    });
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getConversations();
      final data =
          (response['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final list =
          (data['conversations'] as List<dynamic>?) ?? <dynamic>[];
      _conversations
        ..clear()
        ..addAll(list.map((e) => ChatModel.fromJson(
            e as Map<String, dynamic>)));
    } on Exception {
      // Silently fail for now; you can add a snackbar later if needed.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ChatModel> get _filteredConversations {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredConversations;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Messages'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusThirty),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusThirty),
            ),
            color: AppColors.kPrimary.withValues(
              alpha: (0.4 * 255).round().toDouble(),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusThirty),
            ),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.h),
                      child: SearchField(
                        controller: _searchController,
                        isEnabled: true,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      height: AppSpacing.thirtyVertical,
                    ),
                    ColoredBox(
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                      child: _isLoading && filtered.isEmpty
                          ? Padding(
                              padding:
                                  EdgeInsets.all(AppSpacing.twentyHorizontal),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(
                                  AppSpacing.twentyHorizontal),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 30.h),
                              itemBuilder: (content, index) {
                                return ChatCard(
                                  chat: filtered[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
