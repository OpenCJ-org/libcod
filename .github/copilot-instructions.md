# OpenCJ engine instructions

Follow the active shared [OpenCJ coding guidelines](https://github.com/OpenCJ-org/opencj-core/blob/main/dev-tools/agent-guidelines/coding-guidelines.md).
They cover first-party production code, tests and tools across languages.

Inside an opencj-core checkout, read the local canonical file at
`../dev-tools/agent-guidelines/coding-guidelines.md` and the core root
`AGENTS.md`. For a standalone engine checkout, read the linked policy before
editing; do not maintain a separate copy of its rules.

Preserve upstream code outside the deliberately changed OpenCJ blocks,
uncommitted work, untracked files and stashes. Do not restore stashes as part of
cleanup. Use focused new commits rather than rewriting published history.
Keep mechanical readability changes separate from behavior fixes where practical.
When working with core, commit engine changes here and update the core gitlink
explicitly. Do not publish the core pin before the engine commit is available.

Before deployment or environment work, follow the installation's private
operator instructions. A code-cleanup task does not authorize changes to
unrelated services or data.
