@echo off

rem 清理Android mipmap目录中的重复图标文件

echo Cleaning duplicate icon resources...

rem 清理mipmap-hdpi目录
if exist "android\app\src\main\res\mipmap-hdpi\ic_launcher.jpg" (
    del "android\app\src\main\res\mipmap-hdpi\ic_launcher.jpg"
    echo Deleted mipmap-hdpi\ic_launcher.jpg
)

rem 清理mipmap-mdpi目录
if exist "android\app\src\main\res\mipmap-mdpi\ic_launcher.jpg" (
    del "android\app\src\main\res\mipmap-mdpi\ic_launcher.jpg"
    echo Deleted mipmap-mdpi\ic_launcher.jpg
)

rem 清理mipmap-xhdpi目录
if exist "android\app\src\main\res\mipmap-xhdpi\ic_launcher.jpg" (
    del "android\app\src\main\res\mipmap-xhdpi\ic_launcher.jpg"
    echo Deleted mipmap-xhdpi\ic_launcher.jpg
)

rem 清理mipmap-xxhdpi目录
if exist "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.jpg" (
    del "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.jpg"
    echo Deleted mipmap-xxhdpi\ic_launcher.jpg
)

rem 清理mipmap-xxxhdpi目录
if exist "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.jpg" (
    del "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.jpg"
    echo Deleted mipmap-xxxhdpi\ic_launcher.jpg
)

echo Cleaning build directory...
if exist "build" (
    rmdir /s /q "build"
    echo Deleted build directory
)

echo Cleanup completed!
