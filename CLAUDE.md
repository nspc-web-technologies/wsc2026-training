# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Philosophy

This is a competition project implementation. Focus on implementing functionality in the initial code without considering maintainability.

### Key Principles

- **Functionality First**: Implement all required features to meet specification, not for future extensibility
- **No Premature Abstraction**: Write direct code rather than creating reusable components or helper functions
- **Inline Logic**: Keep logic in place rather than extracting to separate modules
- **Minimal Error Handling**: Only validate what the specification requires (e.g., GTIN format, authentication)
- **Quick Solutions**: Use straightforward approaches over architectural patterns
- **No Refactoring**: Once code works, move to next feature rather than improving existing code
- **Specification-Driven**: Only implement what is explicitly required in the marking scheme

### What NOT to Do

- Don't create abstract base classes or interfaces
- Don't extract utility functions unless used 3+ times
- Don't add comprehensive error handling beyond specification
- Don't write automated tests (unless part of requirements)
- Don't optimize performance unless it affects functionality
- Don't add features "for completeness"
- Don't refactor working code for better structure
