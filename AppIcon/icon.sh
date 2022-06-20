mkdir AppIcon.iconset

sips -z 16 16 sidebar.png --out AppIcon.iconset/sidebar_16x16.png
sips -z 32 32 sidebar.png --out AppIcon.iconset/sidebar_16x16@2x.png
sips -z 18 18 sidebar.png --out AppIcon.iconset/sidebar_18x18.png
sips -z 36 36 sidebar.png --out AppIcon.iconset/sidebar_18x18@2x.png
sips -z 24 24 sidebar.png --out AppIcon.iconset/sidebar_24x24.png
sips -z 48 48 sidebar.png --out AppIcon.iconset/sidebar_24x24@2x.png
sips -z 32 32 sidebar.png --out AppIcon.iconset/sidebar_32x32.png
sips -z 64 64 sidebar.png --out AppIcon.iconset/sidebar_32x32@2x.png

sips -z 16 16 AppIcon.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32 AppIcon.png --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32 AppIcon.png --out AppIcon.iconset/icon_32x32.png
sips -z 64 64 AppIcon.png --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128 AppIcon.png --out AppIcon.iconset/icon_128x128.png
sips -z 256 256 AppIcon.png --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256 AppIcon.png --out AppIcon.iconset/icon_256x256.png
sips -z 512 512 AppIcon.png --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512 AppIcon.png --out AppIcon.iconset/icon_512x512.png
sips -z 1024 1024 AppIcon.png --out AppIcon.iconset/icon_512x512@2x.png

iconutil -c icns --output AppIcon.icns AppIcon.iconset

rm -rf AppIcon.iconset
rm -rf ../SwiftyMenu/AppIcon.iconset 2>/dev/null
rm -rf ../SwiftyMenu/AppIcon.icns 2>/dev/null
mv AppIcon.icns ../SwiftyMenu/
