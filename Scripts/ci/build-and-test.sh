set -euo pipefail

cd "$(dirname "$0")/../.."
platform="${1:?Expected macos or ios}"
case "$platform" in
  macos)
    destination='platform=macOS'
    signing=(CODE_SIGN_IDENTITY=-)
    ;;
  ios)
    destination="${IOS_SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0}"
    signing=(CODE_SIGNING_ALLOWED=NO)
    ;;
  *)
    echo "Unknown platform: $platform" >&2
    exit 1
    ;;
esac

derived_data="${DERIVED_DATA_PATH:-$PWD/DerivedData/ci-$platform}"
results="${TEST_RESULTS_PATH:-$PWD/build_out/$platform.xcresult}"
mkdir -p "$(dirname "$results")"

arguments=(
  -project TennoWatch.xcodeproj
  -scheme TennoWatch
  -destination "$destination"
  -derivedDataPath "$derived_data"
  "${signing[@]}"
)

xcodebuild "${arguments[@]}" -configuration Debug test -resultBundlePath "$results"
xcodebuild "${arguments[@]}" -configuration Release build
