name: Build APK
on:
  push:
  workflow_dispatch:
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: 8.7
      - name: Unzip newest zip
        run: |
          f=$(git log --name-only --pretty=format: --diff-filter=AM -- '*.zip' | grep -m1 '\.zip$')
          echo "Using $f"
          unzip -q "$f"
      - run: cd ProCam && gradle assembleDebug
      - env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create v${{ github.run_number }} ProCam/app/build/outputs/apk/debug/app-debug.apk --title "ProCam build ${{ github.run_number }}" --notes "APK"
