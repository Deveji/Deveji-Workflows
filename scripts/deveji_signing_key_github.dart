


keytool -genkey -v -keystore %userprofile%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload


base64 --input "file_path"


gh secret set ANDROID_KEYSTORE_BASE64 --body $(base64 --input ../../lans-app-05-2024.jks)