         #Extracting the values for each field  

          pr_body=$(jq -r ".pull_request.body" "$GITHUB_EVENT_PATH")| 

          # mandatory changelog_start and changelog_end
          
          changelog_start="<!-- [DO NOT REMOVE-USED BY GH ACTION] CHANGELOG START -->"
          changelog_end="<!-- [DO NOT REMOVE-USED BY GH ACTION] CHANGELOG END -->"

          if [[ "$pr_body" != *"$changelog_start"* ]]; then
            echo "[DO NOT REMOVE-USED BY GH ACTION] CHANGELOG START is missing: $changelog_start"
            exit 1
          fi

          if [[ "$pr_body" != *"$changelog_end"* ]]; then
            echo "[DO NOT REMOVE-USED BY GH ACTION] CHANGELOG END is missing: $changelog_end"
            exit 1
          fi

          # Extract and trim each field using pattern matching

          description=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Description:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$description"
          product_impact=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Product Impact:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$product_impact"
          addresses=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Addresses:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$addresses"
          components=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Components:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$components"
          breaking=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Breaking:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$breaking"
          impact_a11y=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Impact_a11y:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$impact_a11y"
          guidance=$(echo "$pr_body" | awk '/## Changelog/{flag=1; next} /##/{flag=0} flag' | grep -oP '(?<=- \*\*Guidance:\*\* ).*' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') echo "$guidance"

         # Default values for each field(According to PR template)

          default_description="Summary of change(s)"
          default_product_impact="Choose from - none (for internal updates) / bugfix / new API / updated API / removed API. If it's 'none', use "-" for all items below to indicate they are not relevant."
          default_addresses="Link(s) to GH issue(s) addressed. Include KDS links as well as links to related issues in a consumer product repository too."
          default_components=" Affected public KDS component. Do not include internal sub-components or documentation components."
          default_breaking=" Will this change break something in a consumer? Choose from: yes / no"
          default_impact_a11y="Does this change improve a11y or adds new features that can be used to improve it? Choose from: yes / no"
          default_guidance=" Why and how to introduce this update to a consumer? Required for breaking changes, appreciated for changes with a11y impact, and welcomed for non-breaking changes when relevant."
          
         # Checking each field with its default value

          if [ -n "$description" ] && [ "$description" != "$default_description" ]; then
            description_valid=true
          else
            description_valid=false
          fi

          if [ -n "$product_impact" ] && [ "$product_impact" != "$default_product_impact" ]; then
            product_impact_valid=true
          else
            product_impact_valid=false
          fi

          if [ -n "$addresses" ] && [ "$addresses" != "$default_addresses" ]; then
            addresses_valid=true
          else
            addresses_valid=false
          fi

          if [ -n "$components" ] && [ "$components" != "$default_components" ]; then
            components_valid=true
          else
            components_valid=false
          fi

          if [ -n "$breaking" ] && [ "$breaking" != "$default_breaking" ]; then
            breaking_valid=true
          else
            breaking_valid=false
          fi

          if [ -n "$impact_a11y" ] && [ "$impact_a11y" != "$default_impact_a11y" ]; then
            impact_a11y_valid=true
          else
            impact_a11y_valid=false
          fi
          if [ -n "$guidance" ] && [ "$guidance" != "$default_guidance" ]; then
            guidance_valid=true
          else
            guidance_valid=false
          fi

         # Results
          echo "containsDescription=$description_valid" >> $GITHUB_OUTPUT
          echo "containsProductImpact=$product_impact_valid" >> $GITHUB_OUTPUT
          echo "containsAddresses=$addresses_valid" >> $GITHUB_OUTPUT
          echo "containsComponents=$components_valid" >> $GITHUB_OUTPUT
          echo "containsBreaking=$breaking_valid" >> $GITHUB_OUTPUT
          echo "containsImpact_a11y=$impact_a11y_valid" >> $GITHUB_OUTPUT
          echo "containsGuidance=$guidance_valid" >> $GITHUB_OUTPUT
          
          # Final validation check
          if [ "$description_valid" = true ] && [ "$product_impact_valid" = true ] && [ "$addresses_valid" = true ]&& [ "$component_impact_valid" = true ]&& [ "$breaking_valid" = true ]&& [ "$impact_a11y_valid" = true ]&& [ "$guidance_valid" = true ]; then
            echo "All required fields are properly filled."
          else
            echo "Changelog section is missing or does not contain the required details."
            exit 1
          fi
