
if [ ! -z "$WATERMARK" ]; then
	sed -i '' '/public class TACSManager {/ a\
    \ \ \ \ private let wm="'$WATERMARK'" \
	' TACS/Classes/TACSManager/TACSManager.swift

    echo "Watermark added"
else
    echo "No watermark defined"
fi
