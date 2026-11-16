#!/bin/bash
# profile-path.sh — VX-999: ONE definition of where the release road reads its pinned Developer ID
# provisioning profile. Sourced by archive-and-export.sh and verify-export.sh, so the two cannot drift
# (the notes-guard.sh precedent).
#
# The profile is kept OUTSIDE the repo, at ~/.variorum/release/Variorum_Developer_ID.provisionprofile,
# and is NEVER committed: the repo is public, and the file was left out of it and its history at the
# flip. The scripts never look beside themselves (Tools/Release/), and .gitignore keeps every
# *.provisionprofile out of the tree. VARIORUM_RELEASE_PROFILE overrides the place
# (Tools/test-release-profile's seam); a release leaves it unset. What is verified against the pinned
# copy is unchanged: the UUID and certificate agreement with ExportOptions.plist, the installed copy in
# Xcode's profiles folder, and the exported bundle's byte-identical embedded.provisionprofile.
#
# Where a copy comes from (the sentence says it in plain words): a Mac that has run the release road
# before holds a byte-identical copy among Xcode's installed profiles (archive-and-export.sh step 2
# installs it there, named by the UUID ExportOptions.plist carries); the private archive clone holds
# the file it used to version. The sentence names no UUID and no path that embeds one.
#
#   release_profile_path          → prints the place on stdout (never fails).
#   release_profile_missing PATH  → true (0), printing ONE sentence on stdout that names where the file
#                                   must be, that it is never committed, and where to copy it from,
#                                   when PATH holds no file; false (1) when it does. The caller wraps the
#                                   sentence in its own refusal or FAIL line and appends nothing.
release_profile_path() {
  printf '%s\n' "${VARIORUM_RELEASE_PROFILE:-${HOME}/.variorum/release/Variorum_Developer_ID.provisionprofile}"
}
release_profile_missing() {
  [ -f "$1" ] && return 1
  echo "the Developer ID provisioning profile must be at $1: the release scripts read it from there, outside the repo, and it is never committed; copy it from Xcode's installed profiles, or from the private archive clone (VX-999)"
  return 0
}
