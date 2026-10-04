#!/bin/sh
#
#  StampBuildNumber.sh — Phase 13r U3-A, R-13r-6 (the version scheme).
#
#  THE BUILD NUMBER IS AUTOMATED ON EVERY BUILD: `git rev-list --count HEAD`
#  is stamped into the built bundle's CFBundleVersion — monotonic and tied to
#  one commit, in EVERY configuration (Debug, Release, the archive). The Mac
#  target's "Stamp Build Number" run-script phase runs this AFTER the
#  Info.plist is processed and BEFORE code signing (the bundle is signed last,
#  so the stamp is inside the seal; a stamp after signing would break it).
#
#  Why every build and not only the release pipeline: her daily drive is a
#  hand-copied tip Release build (R-13r-7). Stamped, it always outranks the
#  appcast, so Sparkle's check runs and offers nothing. Unstamped (the old
#  CFBundleVersion 1), any public appcast entry would be offered to her own
#  machine — the hazard U2 handed forward.
#
#  The release pipeline still passes CURRENT_PROJECT_VERSION = the same count
#  as a command-line override (the archive's own metadata reads the setting),
#  and `verify-export.sh --expect-build` asserts the shipped bundle carries it.
#  This phase writes the SAME number, so the assertion holds either way.
#
#  It refuses (fails the build, loudly) rather than guess: no git, a shallow
#  clone (its count lies), or a count that is not a positive integer.
#
#  The target turns off ENABLE_USER_SCRIPT_SANDBOXING for this reason alone:
#  git must read the repository's .git directory, which no input-file list
#  can name. The phase declares the processed Info.plist as its input so the
#  build system orders it after the file's producer, and is always run.
#
set -eu

plist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

if ! command -v git >/dev/null 2>&1; then
    echo "error: StampBuildNumber: git is not available — the build number cannot be stamped (R-13r-6)." >&2
    exit 1
fi

if [ "$(git -C "${SRCROOT}" rev-parse --is-shallow-repository 2>/dev/null || echo error)" != "false" ]; then
    echo "error: StampBuildNumber: ${SRCROOT} is not a full git checkout (shallow or missing) — a commit count would lie (R-13r-6)." >&2
    exit 1
fi

count="$(git -C "${SRCROOT}" rev-list --count HEAD)"
case "${count}" in
    '' | *[!0-9]* | 0)
        echo "error: StampBuildNumber: 'git rev-list --count HEAD' gave '${count}', not a positive integer (R-13r-6)." >&2
        exit 1
        ;;
esac

if [ ! -f "${plist}" ]; then
    echo "error: StampBuildNumber: no processed Info.plist at ${plist}." >&2
    exit 1
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${count}" "${plist}"
echo "note: StampBuildNumber: CFBundleVersion = ${count} (git rev-list --count HEAD)"
