/// Maps a [TaskProjection] into [PrismDetailSection]s for the
/// [PrismDetailInspector] organism.
///
/// Keeps all Operate-specific semantics out of the generic inspector shell
/// so EPIC 09 can later generalize or absorb this mapper without rewriting
/// the Operate page contract.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Creates the list of [PrismDetailSection]s that represent a single task
/// as a forensic case file inside the inspector.
List<PrismDetailSection> buildTaskDetailSections(TaskProjection task) {
  return [
    _buildMetadataSection(task),
    _buildDependenciesSection(task),
    _buildExitConditionsSection(task),
    _buildVerificationCommandsSection(task),
    _buildEvidenceSection(task),
    _buildRelatedLinksSection(task),
    _buildBodySummarySection(task),
  ];
}

PrismDetailSection _buildMetadataSection(TaskProjection task) {
  return PrismDetailSection(
    title: 'Metadata',
    icon: Icons.info_outline,
    child: Column(
      children: [
        PrismPropertyRow(label: 'ID', value: task.id),
        if (task.slug.isNotEmpty)
          PrismPropertyRow(label: 'Slug', value: task.slug),
        PrismPropertyRow(label: 'Title', value: task.title),
        PrismPropertyRow(
          label: 'Lane',
          value: task.lane.directoryPrefix,
          valueColor: PrismColors.forLane(task.lane.directoryPrefix),
        ),
        if (task.statusLabel.isNotEmpty)
          PrismPropertyRow(label: 'Status', value: task.statusLabel),
        PrismPropertyRow(label: 'Type', value: task.type),
        PrismPropertyRow(label: 'Priority', value: task.priority),
        PrismPropertyRow(label: 'Owner', value: task.owner),
        PrismPropertyRow(label: 'Proof', value: task.proofState.name),
        if (task.reviewScore != null)
          PrismPropertyRow(
            label: 'Review',
            value: task.reviewScore!.toStringAsFixed(1),
          ),
        PrismPropertyRow(label: 'File', value: task.filePath),
      ],
    ),
  );
}

PrismDetailSection _buildDependenciesSection(TaskProjection task) {
  final deps = task.dependsOn;
  final blockers = task.blockers;
  final total = deps.length + blockers.length;
  return PrismDetailSection(
    title: 'Dependencies & Blockers',
    icon: Icons.link,
    count: total,
    child: total == 0
        ? PrismText.bodySmall(
            'No dependencies declared',
            color: PrismColors.textTertiary,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (deps.isNotEmpty)
                Wrap(
                  spacing: PrismSpacing.xs,
                  runSpacing: PrismSpacing.xs,
                  children: deps
                      .map(
                        (dep) => PrismLinkRow(
                          label: dep,
                          icon: PrismIcons.task,
                          color: PrismColors.accentCyan,
                        ),
                      )
                      .toList(),
                ),
              if (blockers.isNotEmpty) ...[
                if (deps.isNotEmpty) const SizedBox(height: PrismSpacing.sm),
                PrismText.labelSmall(
                  'BLOCKERS',
                  color: PrismColors.textTertiary,
                ),
                const SizedBox(height: PrismSpacing.xs),
                Wrap(
                  spacing: PrismSpacing.xs,
                  runSpacing: PrismSpacing.xs,
                  children: blockers
                      .map(
                        (b) => PrismLinkRow(
                          label: b,
                          icon: PrismIcons.task,
                          color: PrismColors.statusError,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
  );
}

PrismDetailSection _buildExitConditionsSection(TaskProjection task) {
  final conditions = task.exitConditions;
  return PrismDetailSection(
    title: 'Exit Conditions',
    icon: Icons.checklist,
    count: conditions.length,
    child: conditions.isEmpty
        ? PrismText.bodySmall(
            'No exit conditions defined',
            color: PrismColors.textTertiary,
          )
        : Column(
            children: conditions
                .map(
                  (ec) => Padding(
                    padding: const EdgeInsets.only(bottom: PrismSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          ec.isComplete
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 16,
                          color: ec.isComplete
                              ? PrismColors.statusSuccess
                              : PrismColors.textTertiary,
                        ),
                        const SizedBox(width: PrismSpacing.sm),
                        Expanded(
                          child: PrismText.bodySmall(
                            ec.text,
                            color: ec.isComplete
                                ? PrismColors.textPrimary
                                : PrismColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

PrismDetailSection _buildVerificationCommandsSection(TaskProjection task) {
  final commands = task.verificationCommands;
  return PrismDetailSection(
    title: 'Verification Commands',
    icon: Icons.terminal,
    count: commands.length,
    child: commands.isEmpty
        ? PrismText.bodySmall(
            'No verification commands',
            color: PrismColors.textTertiary,
          )
        : Column(
            children: commands
                .map(
                  (cmd) => Padding(
                    padding: const EdgeInsets.only(bottom: PrismSpacing.xs),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PrismSpacing.sm),
                      decoration: BoxDecoration(
                        color: PrismColors.obsidianDeep,
                        borderRadius: BorderRadius.circular(PrismRadii.sm),
                        border: Border.all(color: PrismColors.borderSubtle),
                      ),
                      child: PrismText.code(cmd, color: PrismColors.accentCyan),
                    ),
                  ),
                )
                .toList(),
          ),
  );
}

PrismDetailSection _buildEvidenceSection(TaskProjection task) {
  final evidenceState = task.hasCompletionEvidence
      ? PrismEvidenceState.verified
      : (task.proofState == ProofState.partial
            ? PrismEvidenceState.partial
            : (task.proofState == ProofState.complete ||
                      task.proofState == ProofState.verified
                  ? PrismEvidenceState.verified
                  : PrismEvidenceState.pending));

  final rows = task.completionEvidenceRows;
  return PrismDetailSection(
    title: 'Completion Evidence',
    icon: Icons.fact_check,
    count: rows.isEmpty ? null : rows.length,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isEmpty)
          PrismEvidenceRow(
            label: 'Evidence Status',
            value: task.completionEvidenceSummary ?? 'Not yet provided',
            state: evidenceState,
          )
        else
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: PrismSpacing.xs),
              child: PrismEvidenceRow(
                label: row.label ?? 'Evidence',
                value: row.value,
                state: row.isMeaningful
                    ? PrismEvidenceState.verified
                    : PrismEvidenceState.pending,
              ),
            ),
          ),
        if (task.exitConditions.isNotEmpty) ...[
          const SizedBox(height: PrismSpacing.sm),
          PrismEvidenceRow(
            label: 'Checklist progress',
            value:
                '${task.exitConditions.where((e) => e.isComplete).length}/${task.exitConditions.length} complete',
            state: task.exitConditions.every((e) => e.isComplete)
                ? PrismEvidenceState.verified
                : PrismEvidenceState.partial,
          ),
        ],
      ],
    ),
  );
}

PrismDetailSection _buildRelatedLinksSection(TaskProjection task) {
  final skills = task.linkedSkills;
  final workflows = task.linkedWorkflows;
  if (skills.isEmpty && workflows.isEmpty) {
    return PrismDetailSection(
      title: 'Related Skills & Workflows',
      icon: Icons.extension,
      child: PrismText.bodySmall(
        'No linked skills or workflows',
        color: PrismColors.textTertiary,
      ),
    );
  }
  return PrismDetailSection(
    title: 'Related Skills & Workflows',
    icon: Icons.extension,
    count: skills.length + workflows.length,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills.isNotEmpty) ...[
          PrismText.labelSmall('SKILLS', color: PrismColors.textTertiary),
          const SizedBox(height: PrismSpacing.xs),
          Wrap(
            spacing: PrismSpacing.xs,
            runSpacing: PrismSpacing.xs,
            children: skills
                .map(
                  (s) => PrismLinkRow(
                    label: s,
                    icon: PrismIcons.skill,
                    color: PrismColors.accentViolet,
                  ),
                )
                .toList(),
          ),
        ],
        if (workflows.isNotEmpty) ...[
          if (skills.isNotEmpty) const SizedBox(height: PrismSpacing.sm),
          PrismText.labelSmall('WORKFLOWS', color: PrismColors.textTertiary),
          const SizedBox(height: PrismSpacing.xs),
          Wrap(
            spacing: PrismSpacing.xs,
            runSpacing: PrismSpacing.xs,
            children: workflows
                .map(
                  (w) => PrismLinkRow(
                    label: w,
                    icon: PrismIcons.workflow,
                    color: PrismColors.accentGold,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    ),
  );
}

PrismDetailSection _buildBodySummarySection(TaskProjection task) {
  final body = task.bodyMarkdown.trim();
  return PrismDetailSection(
    title: 'Body Summary',
    icon: Icons.description,
    child: body.isEmpty
        ? PrismText.bodySmall(
            'No body content',
            color: PrismColors.textTertiary,
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PrismSpacing.md),
            decoration: BoxDecoration(
              color: PrismColors.obsidianDeep,
              borderRadius: BorderRadius.circular(PrismRadii.md),
              border: Border.all(color: PrismColors.borderSubtle),
            ),
            child: PrismText.bodySmall(
              body.length > 500 ? '${body.substring(0, 500)}...' : body,
              color: PrismColors.textSecondary,
              maxLines: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
  );
}
