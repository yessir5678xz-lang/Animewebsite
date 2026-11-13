# Blender Seinen Art Direction

This repository includes a reusable agent skill for producing Blender assets with the project's original monochrome seinen visual direction.

## Skill location

`.claude/skills/blender-seinen-art-direction/SKILL.md`

The skill defines repository-first inspection, Blender Python automation, asset workflows, monochrome ink look development, anatomy, material rendering, environmental detail, combat visualization, Godot export checks, and quality gates.

## Use with Claude Code

Claude Code can discover project skills under `.claude/skills/<skill-name>/SKILL.md`. Start Claude Code in this repository and ask it to create or refine an asset. For example:

> Read `.claude/skills/blender-seinen-art-direction/SKILL.md` completely. Inspect the existing project assets and Blender/Godot pipeline. Create an original monochrome cinematic environment study for the requested region. Preserve established lore, paths, scale and export conventions. Validate the Blender source and Godot import before reporting completion.

If the model does not automatically discover the skill, explicitly reference the path in the task prompt.

## Model compatibility

The instructions are written as plain Markdown for Claude-style coding agents and other capable repository agents. They do not depend on a specific model identifier or a private model-only feature. Use the actual model name exposed by your Claude deployment; verify availability rather than assuming a model called "Claude Opus 5.5" exists.

## Art direction

- Original Gritty Cinematic Realism.
- Traditional monochrome manga presentation: black ink, white paper, grayscale, cross-hatching, stippling and controlled screentones.
- Believable anatomy and material-specific construction.
- Detailed environments with atmospheric depth and readable composition.
- Clear combat choreography and consistent spatial continuity.
- No tracing, panel replication, or copying protected characters or signature designs.

## Important

This skill is an instruction set, not an automatic Blender installation or a completed asset-generation pipeline. The agent must inspect the installed Blender version and the project's real asset/export pipeline before implementation.
