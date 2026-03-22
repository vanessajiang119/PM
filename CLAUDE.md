# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **chip design process automation** project using the ruflo framework (claude-flow v3.5). It defines an agent system for managing the complete chip development flow from specification to GDS.

## Key Files

- `define.yml` - Main agent system definition for chip R&D workflow
- `reference/ruflo/` - Reference materials for ruflo framework

## Architecture

The project defines a multi-phase chip design workflow with specialized agents:

1. **Specification Phase** - spec-architect, spec-writer, spec-reviewer
2. **RTL Development** - rtl-developer, verification-engineer, debug-engineer, rtl-reviewer
3. **Synthesis** - synthesis-engineer, dft-engineer, formal-verification-engineer
4. **Physical Design** - physical-designer, sta-engineer, physical-verification-engineer
5. **GDS Output** - gds-engineer, tapeout-reviewer

## Working with This Project

- Read `define.yml` to understand the complete agent taxonomy and workflow definitions
- Reference `reference/ruflo/CLAUDE.md` and `reference/ruflo/AGENTS.md` for ruflo framework details
- The ruflo skills are located in `reference/ruflo/.agents/skills/`
