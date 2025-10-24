# Changelog

## v0.3.0 (24 October 2025)

- Add `attr_evaluated` to define attributes that are evaluated/computed at runtime (#32)
- Use including class name for error messages (#31)

## v0.2.0 (20 June 2025)

### Added

- `standardrb` gem for linting (#11)
- `.where` method for finding multiple records with an array of IDs (#16)
- `.ids` method which returns an array of all record IDs (#25)
- `.find_by` method to return the first method matching a specific condition (#26)
- `.find_by!` method which behaves like `find_by` but raises when a matching
   record is not found (#28)

### Changed
- Use GitHub Actions for CI (#10)
- Refactor specs to be more inline with thoughtbot style (#15)
- Require `activesupport` v7.1.0 or higher (#22)
- Coerce `.find_by_id` argument to integer (#23)
- More descriptive exception messages (#24)
