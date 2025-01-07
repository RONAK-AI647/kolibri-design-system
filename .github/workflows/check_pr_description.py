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