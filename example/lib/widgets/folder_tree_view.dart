import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class FileTreeNode {
  final String name;
  final bool isDirectory;
  final String? description;
  final List<FileTreeNode>? children;

  const FileTreeNode({
    required this.name,
    this.isDirectory = false,
    this.description,
    this.children,
  });
}

class FolderTreeView extends StatelessWidget {
  final String title;
  final List<FileTreeNode> nodes;

  const FolderTreeView({
    super.key,
    required this.title,
    required this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open_rounded, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF1E293B), height: 24),
          ...nodes.map((node) => _buildNode(node, 0)),
        ],
      ),
    );
  }

  Widget _buildNode(FileTreeNode node, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                node.isDirectory ? Icons.folder : Icons.insert_drive_file_outlined,
                size: 16,
                color: node.isDirectory ? AppTheme.accentOrange : AppTheme.accentGreen,
              ),
              const SizedBox(width: 8),
              Text(
                node.name,
                style: TextStyle(
                  color: node.isDirectory ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: node.isDirectory ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              if (node.description != null) ...[
                const SizedBox(width: 8),
                Text(
                  '// ${node.description}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          if (node.children != null)
            ...node.children!.map((child) => _buildNode(child, depth + 1)),
        ],
      ),
    );
  }
}
