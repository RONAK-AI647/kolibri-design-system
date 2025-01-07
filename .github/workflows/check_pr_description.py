import os
import json
import re

# Define default values for each field (according to the PR template)
DEFAULT_VALUES = {
    "Description": "Summary of change(s)",
    "Product Impact": "Choose from - none (for internal updates) / bugfix / new API / updated API / removed API. If it's 'none', use '-' for all items below to indicate they are not relevant.",
    "Addresses": "Link(s) to GH issue(s) addressed. Include KDS links as well as links to related issues in a consumer product repository too.",
    "Components": "Affected public KDS component. Do not include internal sub-components or documentation components.",
    "Breaking": "Will this change break something in a consumer? Choose from: yes / no",
    "Impact_a11y": "Does this change improve a11y or add new features that can be used to improve it? Choose from: yes / no",
    "Guidance": "Why and how to introduce this update to a consumer? Required for breaking changes, appreciated for changes with a11y impact, and welcomed for non-breaking changes when relevant."
}

def get_pr_description(event_path):
    """Extract PR description from the GitHub event payload."""
    with open(event_path, 'r') as f:
        event_data = json.load(f)
    return event_data['pull_request']['body']

def check_field(description, field_name):
    """Check if the field in the PR description is different from its default value."""
    pattern = r"(?<=- \*\*{}:\*\* ).*".format(re.escape(field_name))
    match = re.search(pattern, description)
    if match:
        field_value = match.group(0).strip()
        return field_value != DEFAULT_VALUES[field_name]
    return False


def validate_changelog(description):
    """Check if the changelog start and end markers are present in the PR description."""
    changelog_start = "<!-- [DO NOT REMOVE-USED BY GH ACTION] CHANGELOG START -->"
    changelog_end = "<!-- [DO NOT REMOVE-USED BY GH ACTION] CHANGELOG END -->"
    
    if changelog_start not in description:
        print(f"[DO NOT REMOVE-USED BY GH ACTION] CHANGELOG START is missing: {changelog_start}")
        return False
    if changelog_end not in description:
        print(f"[DO NOT REMOVE-USED BY GH ACTION] CHANGELOG END is missing: {changelog_end}")
        return False
    return True



def check_pr_description(event_path):
    """Check all fields in the PR description and validate their values."""
    description = get_pr_description(event_path)
    
    # Check if changelog markers are present
    if not validate_changelog(description):
        return False
    
    # Check each field against the default value
    results = {}
    for field_name in DEFAULT_VALUES.keys():
        is_valid = check_field(description, field_name)
        results[field_name] = is_valid
        print(f"{field_name}: {'Valid' if is_valid else 'Invalid'}")
    
    return results



def main():
    event_path = os.getenv('GITHUB_EVENT_PATH')
    if not event_path:
        print("Error: GITHUB_EVENT_PATH environment variable is not set.")
        exit(1)

    results = check_pr_description(event_path)
    
    # Set output variables for GitHub Actions
    for field, valid in results.items():
        print(f"contains{field.replace(' ', '')}={str(valid).lower()}")

           
    # Final validation check: Ensure all fields are valid
    if all(results.values()):
        print("All required fields are properly filled.")
        exit(0)
    else:
        print("Changelog section is missing or does not contain the required details.")
        exit(1)

if __name__ == "__main__":
    main()
    