.PHONY: init diagrams help

help:
	@echo "Available targets:"
	@echo "  make init      - Run the post-init hook (deps snapshot + structure tree)"
	@echo "  make diagrams  - Reminder to run /init in Claude Code"

init:
	@bash .claude/hooks/post_init.sh
	@echo "Now run /init inside Claude Code to sync all docs, ADRs, diagrams and flows"

diagrams:
	@echo "Run /init inside Claude Code to regenerate all diagrams and flows"
