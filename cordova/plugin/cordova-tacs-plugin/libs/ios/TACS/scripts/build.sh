
# Build framework using carthage and copy build artefacts into BUILD folder
# CARTHAGE_NO_VERBOSE flag turns off the verbose log of carthage which led to issues, see https://github.com/Carthage/Carthage/issues/2249 for details
if [ "$STATIC_BUILD" = true ] ; then
	echo "The build will include a static version..."
	export INCLUDE_STATIC_BUILD=1
fi
CARTHAGE_NO_VERBOSE=1 sh scripts/build_release.sh
cp -r BUILD Libs
