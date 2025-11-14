.PHONY: help tree

help:
	@echo "Targets:"
	@echo "  help  - show this help"
	@echo "  tree  - print live repo tree (top-level)"

tree:
	@powershell -NoProfile -Command "Get-ChildItem -Recurse -Depth 2 | Format-Table FullName"

