/// Maps a [TaskProjection] into [DSDetailSection]s for the
/// [DSDetailInspector] organism.
///
/// Keeps all Operate-specific semantics out of the generic inspector shell
/// so EPIC 09 can later generalize or absorb this mapper without rewriting
/// the Operate page contract.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../../data/models/task_contracts.dart';
import 'task_projection.dart';

/// Creates the list of [DSDetailSection]s that represent a single task
/// as a forensic case file inside the inspector.
List<DSDetailSection> buildTaskDetailSections(TaskProjection task) {
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

DSDetailSection _buildMetadataSection(TaskProjection task) {
  return DSDetailSection(
    title: 'Metadata',
    icon: Icons.info_outline,
    child: Column(
      children: [
        DSPropertyRow(label: 'ID', value: task.id),
        DSPropertyRow(label: 'Title', value: task.title),
        DSPropertyRow(
          label: 'Lane',
          value: task.lane.directoryPrefix,
          valueColor: DSColors.forLane(task.lane.directoryPrefix),
        ),
        DSPropertyRow(label: 'Priority', value: task.priority),
        DSPropertyRow(label: 'Owner', value: task.owner),
        DSPropertyRow(label: 'Proof', value: task.proofState.name),
        if (task.reviewScore != null)
          DSPropertyRow(
            label: 'Review',
            value: task.reviewScore!.toStringAsFixed(1),
          ),
        DSPropertyRow(label: 'File', value: task.filePath),
      ],
    ),
  );
}

DSDetailSection _buildDependenciesSection(TaskProjection task) {
  final deps = task.dependsOn;
  return DSDetailSection(
    title: 'Dependencies & Blockers',
    icon: Icons.link,
    count: deps.length,
    child: deps.isEmpty
        ? DSText.bodySmall(
            'No dependencies declared',
            color: DSColors.textTertiary,
          )
        : Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: deps
                .map((dep) => DSLinkRow(
                      label: dep,
                      icon: DSIcons.task,
                      color: DSColors.accentCyan,
                    ))
                .toList(),
          ),
  );
}

DSDetailSection _buildExitConditionsSection(TaskProjection task) {
  final conditions = task.exitConditions;
  return DSDetailSection(
    title: 'Exit Conditions',
    icon: Icons.checklist,
    count: conditions.length,
    child: conditions.isEmpty
        ? DSText.bodySmall(
            'No exit conditions defined',
            color: DSColors.textTertiary,
          )
        : Column(
            children: conditions
                .map((ec) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                      child: Row(
                        children: [
                          Icon(
                            ec.isComplete
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: ec.isComplete
                                ? DSColors.statusSuccess
                                : DSColors.textTertiary,
                          ),
                          const SizedBox(width: DSSpacing.sm),
                          Expanded(
                            child: DSText.bodySmall(
                              ec.text,
                              color: ec.isComplete
                                  ? DSColors.textPrimary
                                  : DSColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
  );
}

DSDetailSection _buildVerificationCommandsSection(TaskProjection task) {
  final commands = task.verificationCommands;
  return DSDetailSection(
    title: 'Verification Commands',
    icon: Icons.terminal,
    count: commands.length,
    child: commands.isEmpty
        ? DSText.bodySmall(
            'No verification commands',
            color: DSColors.textTertiary,
          )
        : Column(
            children: commands
                .map((cmd) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DSSpacing.sm),
                        decoration: BoxDecoration(
                          color: DSColors.obsidianDeep,
                          borderRadius: BorderRadius.circular(DSRadii.sm),
                          border: Border.all(color: DSColors.borderSubtle),
                        ),
                        child: DSText.code(
                          cmd,
                          color: DSColors.accentCyan,
                        ),
                      ),
                    ))
                .toList(),
          ),
  );
}

DSDetailSection _buildEvidenceSection(TaskProjection task) {
  final evidenceState = task.hasCompletionEvidence
      ? DSEvidenceState.verified
      : (task.proofState == ProofState.partial
          ? DSEvidenceState.partial
          : (task.proofState == ProofState.complete ||
                  task.proofState == ProofState.verified
              ? DSEvidenceState.verified
              : DSEvidenceState.pending));

  return DSDetailSection(
    title: 'Completion Evidence',
    icon: Icons.fact_check,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSEvidenceRow(
          label: 'Evidence Status',
          value: task.completionEvidenceSummary ?? 'Not yet provided',
          state: evidenceState,
        ),
        if (task.exitConditions.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          DSEvidenceRow(
            label: 'Exit Conditions',
            value:
                '${task.exitConditions.where((e) => e.isComplete).length}/${task.exitConditions.length} complete',
            state: task.exitConditions.every((e) => e.isComplete)
                ? DSEvidenceState.verified
                : DSEvidenceState.partial,
          ),
        ],
      ],
    ),
  );
}

DSDetailSection _buildRelatedLinksSection(TaskProjection task) {
  final skills = task.linkedSkills;
  final workflows = task.linkedWorkflows;
  if (skills.isEmpty && workflows.isEmpty) {
    return DSDetailSection(
      title: 'Related Skills & Workflows',
      icon: Icons.extension,
      child: DSText.bodySmall(
        'No linked skills or workflows',
        color: DSColors.textTertiary,
      ),
    );
  }
  return DSDetailSection(
    title: 'Related Skills & Workflows',
    icon: Icons.extension,
    count: skills.length + workflows.length,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills.isNotEmpty) ...[
          DSText.labelSmall('SKILLS', color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: skills
                .map((s) => DSLinkRow(
                      label: s,
                      icon: DSIcons.skill,
                      color: DSColors.accentViolet,
                    ))
                .toList(),
          ),
        ],
        if (workflows.isNotEmpty) ...[
          if (skills.isNotEmpty) const SizedBox(height: DSSpacing.sm),
          DSText.labelSmall('WORKFLOWS', color: DSColors.textTertiary),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: workflows
                .map((w) => DSLinkRow(
                      label: w,
                      icon: DSIcons.workflow,
                      color: DSColors.accentGold,
                    ))
                .toList(),
          ),
        ],
      ],
    ),
  );
}

DSDetailSection _buildBodySummarySection(TaskProjection task) {
  final body = task.bodyMarkdown.trim();
  return DSDetailSection(
    title: 'Body Summary',
    icon: Icons.description,
    child: body.isEmpty
        ? DSText.bodySmall(
            'No body content',
            color: DSColors.textTertiary,
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: DSColors.obsidianDeep,
              borderRadius: BorderRadius.circular(DSRadii.md),
              border: Border.all(color: DSColors.borderSubtle),
            ),
            child: DSText.bodySmall(
              body.length > 500 ? '${body.substring(0, 500)}...' : body,
              color: DSColors.textSecondary,
              maxLines: 12,
              overflow: TextOverflow.ellipsis,
            ),
          ),
  );
}
