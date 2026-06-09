/// Universal asset detail descriptor for the Warp-Prism ASW Observatory.
///
/// One normalized contract that turns any [WorkspaceAsset] plus its
/// incoming/outgoing edges into an inspector-ready descriptor with
/// shared sections for identity, metadata, body summary, related assets,
/// and unsupported-kind fallback.
library;

import 'package:flutter/foundation.dart';

import '../../../data/models/workspace_graph.dart';
import '../../../data/models/task_contracts.dart';
import '../../../data/models/changelog_contracts.dart';

/// A single renderable section inside the universal detail inspector.
@immutable
class DetailSection {
  /// Section title (e.g., "Identity", "Dependencies").
  final String title;

  /// Semantic section key for kind-specific filtering.
  final String key;

  /// Icon name hint for the presentation layer.
  final String? iconHint;

  /// Count badge (null = no badge).
  final int? count;

  /// Structured property rows for this section.
  final List<DetailProperty> properties;

  /// Link items (navigable related assets).
  final List<DetailLink> links;

  /// Code blocks (verification commands, etc.).
  final List<String> codeBlocks;

  /// Whether this section is kind-specific (vs. shared across all kinds).
  final bool kindSpecific;

  const DetailSection({
    required this.title,
    required this.key,
    this.iconHint,
    this.count,
    this.properties = const [],
    this.links = const [],
    this.codeBlocks = const [],
    this.kindSpecific = false,
  });
}

/// A single label/value property row.
@immutable
class DetailProperty {
  final String label;
  final String value;
  final String? semanticHint;

  const DetailProperty({
    required this.label,
    required this.value,
    this.semanticHint,
  });
}

/// A navigable link to a related asset.
@immutable
class DetailLink {
  final String targetId;
  final String label;
  final String kind;

  const DetailLink({
    required this.targetId,
    required this.label,
    required this.kind,
  });
}

/// Universal descriptor for an asset's detail view.
///
/// Contains everything the presentation layer needs to render a complete
/// inspector for any asset kind. Kind-specific views consume these sections
/// and compose them into their own layout.
@immutable
class AssetDetailDescriptor {
  /// The source asset.
  final WorkspaceAsset asset;

  /// Shared sections rendered for every asset kind.
  final List<DetailSection> sharedSections;

  /// Kind-specific sections only relevant to this asset kind.
  final List<DetailSection> kindSections;

  /// Incoming edges (other assets referencing this one).
  final List<DetailLink> incomingLinks;

  /// Outgoing edges (assets this one references).
  final List<DetailLink> outgoingLinks;

  /// Whether this descriptor is a fallback (unsupported or partial).
  final bool isFallback;

  /// Fallback message when [isFallback] is true.
  final String? fallbackMessage;

  /// Task-specific metadata (only present for task assets).
  final TaskMetadata? taskMetadata;

  /// Changelog-specific metadata (only present for changelog assets).
  final ChangelogMetadata? changelogMetadata;

  const AssetDetailDescriptor({
    required this.asset,
    this.sharedSections = const [],
    this.kindSections = const [],
    this.incomingLinks = const [],
    this.outgoingLinks = const [],
    this.isFallback = false,
    this.fallbackMessage,
    this.taskMetadata,
    this.changelogMetadata,
  });

  /// All sections (shared + kind-specific) in display order.
  List<DetailSection> get allSections => [...sharedSections, ...kindSections];

  /// Total link count (incoming + outgoing).
  int get totalLinkCount => incomingLinks.length + outgoingLinks.length;

  /// Whether this descriptor has any content at all.
  bool get hasContent =>
      sharedSections.isNotEmpty ||
      kindSections.isNotEmpty ||
      incomingLinks.isNotEmpty ||
      outgoingLinks.isNotEmpty;

  /// Creates a fallback descriptor for unsupported or partially-supported kinds.
  factory AssetDetailDescriptor.fallback({
    required WorkspaceAsset asset,
    String message = 'This asset kind has limited detail support.',
  }) {
    return AssetDetailDescriptor(
      asset: asset,
      sharedSections: [
        DetailSection(
          title: 'Identity',
          key: 'identity',
          properties: [
            DetailProperty(label: 'ID', value: asset.id),
            DetailProperty(label: 'Kind', value: asset.kind.name),
            DetailProperty(label: 'Path', value: asset.path),
            DetailProperty(label: 'Provenance', value: asset.canonicality.name),
            if (asset.description.isNotEmpty)
              DetailProperty(label: 'Description', value: asset.description),
          ],
        ),
        if (asset.frontmatter.isNotEmpty)
          DetailSection(
            title: 'Metadata',
            key: 'metadata',
            count: asset.frontmatter.length,
            properties: asset.frontmatter.entries
                .where((e) => !e.key.startsWith('_'))
                .take(10)
                .map((e) => DetailProperty(
                      label: e.key,
                      value: _formatValue(e.value),
                    ))
                .toList(),
          ),
        if (asset.tags.isNotEmpty || asset.triggers.isNotEmpty)
          DetailSection(
            title: 'Tags & Triggers',
            key: 'tags',
            properties: [
              if (asset.tags.isNotEmpty)
                DetailProperty(label: 'Tags', value: asset.tags.join(', ')),
              if (asset.triggers.isNotEmpty)
                DetailProperty(
                    label: 'Triggers', value: asset.triggers.join(', ')),
            ],
          ),
      ],
      isFallback: true,
      fallbackMessage: message,
    );
  }

  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return value.join(', ');
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    return value.toString();
  }
}
