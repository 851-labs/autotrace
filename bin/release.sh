#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print usage information
function usage {
  echo -e "Usage: $0 [patch|minor|major|version_number]"
  echo -e "Examples:"
  echo -e "  $0 patch  # Increments the patch version (0.1.0 -> 0.1.1)"
  echo -e "  $0 minor  # Increments the minor version (0.1.1 -> 0.2.0)"
  echo -e "  $0 major  # Increments the major version (0.2.0 -> 1.0.0)"
  echo -e "  $0 1.2.3  # Sets a specific version"
  exit 1
}

# Check for the correct number of arguments
if [ $# -ne 1 ]; then
  echo -e "${RED}Error: Incorrect number of arguments${NC}"
  usage
fi

# Get the version type or specific version
VERSION_ARG=$1

# Make sure we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo -e "${RED}Error: Not in a git repository${NC}"
  exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted${NC}"
    exit 1
  fi
fi

# Get current version from gemspec file
GEMSPEC_FILE=$(find . -name "*.gemspec" | head -n 1)
if [ -z "$GEMSPEC_FILE" ]; then
  echo -e "${RED}Error: No gemspec file found${NC}"
  exit 1
fi

CURRENT_VERSION=$(grep -oE "version\s*=\s*['\"]([0-9]+\.[0-9]+\.[0-9]+)['\"]" "$GEMSPEC_FILE" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
if [ -z "$CURRENT_VERSION" ]; then
  echo -e "${RED}Error: Could not find version in gemspec file${NC}"
  exit 1
fi

echo -e "${GREEN}Current version: ${CURRENT_VERSION}${NC}"

# Calculate the new version
if [[ "$VERSION_ARG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # Specific version provided
  NEW_VERSION=$VERSION_ARG
else
  # Version type provided
  IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
  MAJOR=${VERSION_PARTS[0]}
  MINOR=${VERSION_PARTS[1]}
  PATCH=${VERSION_PARTS[2]}

  case $VERSION_ARG in
    patch)
      PATCH=$((PATCH + 1))
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    *)
      echo -e "${RED}Error: Invalid version argument. Expected 'patch', 'minor', 'major', or a specific version number (e.g., '1.2.3')${NC}"
      usage
      ;;
  esac

  NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
fi

echo -e "${GREEN}New version will be: ${NEW_VERSION}${NC}"
read -p "Continue with release? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}Release aborted${NC}"
  exit 1
fi

# Update version in gemspec
sed -i.bak "s/version\s*=\s*['\"]${CURRENT_VERSION}['\"]/version = '${NEW_VERSION}'/" "$GEMSPEC_FILE"
rm "${GEMSPEC_FILE}.bak"

# Update version in version.rb file (if exists)
VERSION_RB_FILE=$(find . -path "*/lib/*/version.rb" 2>/dev/null | head -n 1)
if [ -n "$VERSION_RB_FILE" ]; then
  sed -i.bak "s/VERSION\s*=\s*['\"]${CURRENT_VERSION}['\"]/VERSION = '${NEW_VERSION}'/" "$VERSION_RB_FILE"
  rm "${VERSION_RB_FILE}.bak"
fi

# Commit the version change
git add "$GEMSPEC_FILE"
if [ -n "$VERSION_RB_FILE" ]; then
  git add "$VERSION_RB_FILE"
fi

git commit -m "Bump version to ${NEW_VERSION}"

# Create a version tag
git tag -a "v${NEW_VERSION}" -m "Version ${NEW_VERSION}"

echo -e "${GREEN}Created commit and tag for version ${NEW_VERSION}${NC}"

# Ask if we should push to remote
read -p "Push changes and tag to remote repository? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git push origin main
  git push origin "v${NEW_VERSION}"
  echo -e "${GREEN}Pushed changes and tag to remote repository${NC}"
  echo -e "${YELLOW}GitHub Actions workflow should now build and release the gem to RubyGems.org${NC}"
else
  echo -e "${YELLOW}Remember to push the changes and tag yourself:${NC}"
  echo "  git push origin main"
  echo "  git push origin v${NEW_VERSION}"
fi

echo -e "${GREEN}Release process completed!${NC}" 