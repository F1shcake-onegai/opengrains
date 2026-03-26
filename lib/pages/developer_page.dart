import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/developer_settings.dart';
import '../services/error_log.dart';
import '../services/app_localizations.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  bool _verbose = DeveloperSettings.verbose;
  int _logCap = DeveloperSettings.logCap;
  int _logAgeDays = DeveloperSettings.logAgeDays;

  Future<void> _confirmClearAll(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('dev_clear_logs')),
        content: Text(l.t('dev_clear_logs_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.t('dev_clear'),
                style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ErrorLog.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.t('dev_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: Text(l.t('dev_verbose')),
              subtitle: Text(l.t('dev_verbose_desc'),
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
              value: _verbose,
              onChanged: (v) async {
                await DeveloperSettings.setVerbose(v);
                setState(() => _verbose = v);
              },
            ),
            const Divider(),

            // Log cap
            ListTile(
              title: Text(l.t('dev_log_cap')),
              subtitle: Text(l.t('dev_log_cap_desc'),
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<int>(
                  value: _logCap,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: DeveloperSettings.logCapOptions
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) async {
                    if (v != null) {
                      await DeveloperSettings.setLogCap(v);
                      setState(() => _logCap = v);
                    }
                  },
                ),
              ),
            ),

            // Log age
            ListTile(
              title: Text(l.t('dev_log_age')),
              subtitle: Text(l.t('dev_log_age_desc'),
                  style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant)),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<int>(
                  value: _logAgeDays,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: DeveloperSettings.logAgeOptions
                      .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(DeveloperSettings.logAgeLabel(v))))
                      .toList(),
                  onChanged: (v) async {
                    if (v != null) {
                      await DeveloperSettings.setLogAgeDays(v);
                      setState(() => _logAgeDays = v);
                    }
                  },
                ),
              ),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l.t('dev_error_logs')),
              subtitle: Text(
                l.t('dev_error_logs_count',
                    {'count': ErrorLog.entries.length.toString()}),
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const _ErrorLogListPage()),
              ).then((_) => setState(() {})),
              onLongPress: ErrorLog.entries.isNotEmpty
                  ? () => _confirmClearAll(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorLogListPage extends StatefulWidget {
  const _ErrorLogListPage();

  @override
  State<_ErrorLogListPage> createState() => _ErrorLogListPageState();
}

class _ErrorLogListPageState extends State<_ErrorLogListPage> {
  Future<void> _exportLogs() async {
    final l = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : Rect.zero;
    try {
      final path = await ErrorLog.exportLog();
      await Share.shareXFiles([XFile(path)],
          sharePositionOrigin: origin);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('export_error'))),
        );
      }
    }
  }

  Future<void> _confirmDeleteEntry(ErrorEntry entry) async {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.t('dev_delete_entry')),
        content: Text(l.t('dev_delete_entry_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.t('dev_delete'),
                style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ErrorLog.deleteEntry(entry);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final entries = ErrorLog.entries.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.t('dev_error_logs')),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: _exportLogs,
            ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(l.t('dev_no_logs'),
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final time =
                    '${entry.timestamp.month}/${entry.timestamp.day} '
                    '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
                    '${entry.timestamp.second.toString().padLeft(2, '0')}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.source,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    entry.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Text(time,
                      style: TextStyle(
                          fontSize: 11, color: colorScheme.onSurfaceVariant)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _ErrorDetailPage(entry: entry)),
                  ).then((_) => setState(() {})),
                  onLongPress: () => _confirmDeleteEntry(entry),
                );
              },
            ),
    );
  }
}

class _ErrorDetailPage extends StatelessWidget {
  final ErrorEntry entry;

  const _ErrorDetailPage({required this.entry});

  void _copyToClipboard(BuildContext context) {
    final l = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: entry.toDisplayString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.t('dev_copied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final time =
        '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-'
        '${entry.timestamp.day.toString().padLeft(2, '0')} '
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l.t('dev_error_detail')),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(l.t('dev_error_time'), time, colorScheme),
            const SizedBox(height: 16),
            _section(l.t('dev_error_source'), entry.source, colorScheme),
            const SizedBox(height: 16),
            _section(l.t('dev_error_message'), entry.message, colorScheme),
            if (entry.stackTrace != null) ...[
              const SizedBox(height: 16),
              _section(
                  l.t('dev_error_stack'), entry.stackTrace!, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(String label, String content, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        SelectableText(content,
            style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
