# Changelog Entry: 2025-04-10

## Summary
Initial release of the Planner Agent for strategic project planning and task decomposition.

## Changes

### Added
- New Planner Agent for project planning and task management
- Planning skill with effort estimation and dependency analysis
- Risk assessment capabilities
- Integration with external project management tools (Jira, Linear)
- Sprint planning workflow

### Changed
- Orchestrator can now delegate planning tasks to Planner
- Task decomposition moved from Orchestrator to Planner for better separation

## Affected Assets
- Agent: planner (v1.0.0 -> v1.2.0)
- Skill: planning (v1.0.0 -> v1.0.2)
- Skill: estimation (v1.0.0)
- Workflow: planning-cycle (v1.0.0)
- Workflow: sprint-planning (v1.0.0)

## Evidence
- Design doc: Planner Agent Architecture
- Beta test results: 89% accuracy in effort estimation
- User study: 45% reduction in planning overhead

## Author
@asw-team

## Tags
- new-feature
- planner
- project-management
