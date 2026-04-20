# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Training repository for WorldSkills Competition 2026. Each module subdirectory may contain task specifications (`tp/`), design documents (`design/`), and implementations (`implementation/`).

## Tech Stacks

### 1_2024_frontend (Module E - Frontend)

- Framework: Vue 3 + Vue Router 4
- Build: Vite 7
- UI: Headless UI for Vue
- Path: `1_2024_frontend/implementation/vue/`
- Dev: `npm run dev`

### 2_2024_backend (Module B - Backend)

- Framework: Laravel 12 (PHP 8.2+)
- DB: MySQL
- Path: `2_2024_backend/implementation/laravel/`
- Dev: `composer dev` (serves app, queue, logs, vite concurrently)
- DocumentRoot: `17_module_b/` (replaces default `public/`)

### 3_2025_restful_api (Module C - RESTful API)

- Framework: Laravel (PHP 8.2+)
- DB: MySQL/MariaDB
- Path: `3_2025_restful_api/` (design phase, implementation not started)

### 4_2024_speedtest (Module A - Speed Test)

- Stack: Vanilla HTML/JS
- Path: `4_2024_speedtest/implementation/`

### 5_2024_mobile-app (Module D - Mobile App)

React implementation:

- Framework: React 19 + React Router 7
- Build: Vite 8
- Path: `5_2024_mobile-app/implementation/react/`
- Dev: `npm run dev`

Vue implementation:

- Framework: Vue 3 + Vue Router 4
- Build: Vite 7
- UI: Headless UI for Vue
- Path: `5_2024_mobile-app/implementation/vue/`
- Dev: `npm run dev`

### training_environment

- Docker Compose environment for local/GCE server setup
- Path: `training_environment/server/`

## Markdown Formatting

- Do not use bold (`**`). Use headings or plain text instead
- Do not use horizontal rules (`---`). Use headings to separate sections
- Use `####` (h4) for structural sub-labels (e.g., Fields, Request, Response) when parent is `###` (h3)
- Use plain text for labels that are not independent sections (e.g., introductory labels under `##`)
- Maintain correct heading hierarchy — do not skip levels (e.g., `##` → `####`)
- Always leave a blank line before and after headings

## Development Philosophy

This is a competition project implementation. Focus on implementing functionality in the initial code without considering maintainability.

### Key Principles

- Functionality First: Implement all required features to meet specification, not for future extensibility
- No Premature Abstraction: Write direct code rather than creating reusable components or helper functions
- Inline Logic: Keep logic in place rather than extracting to separate modules
- Minimal Error Handling: Only validate what the specification requires (e.g., GTIN format, authentication)
- Quick Solutions: Use straightforward approaches over architectural patterns
- No Refactoring: Once code works, move to next feature rather than improving existing code
- Specification-Driven: Only implement what is explicitly required in the marking scheme

### What NOT to Do

- Don't create abstract base classes or interfaces
- Don't extract utility functions unless used 3+ times
- Don't add comprehensive error handling beyond specification
- Don't write automated tests (unless part of requirements)
- Don't optimize performance unless it affects functionality
- Don't add features "for completeness"
- Don't refactor working code for better structure
