# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# Only the below variable(s) need to be changed!
VERSION_MAJOR=3
VERSION_MINOR=1
VERSION_PATCH=0

# The below variables will be generated automatically
#
# Version name
ROM_VERSION="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"

# Append current commit hash to version name
ROM_VERSION+="-$(git rev-parse --short HEAD 2> /dev/null || echo "null")"
