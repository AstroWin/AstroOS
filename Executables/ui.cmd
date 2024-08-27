rmdir /S /Q %windir%\Web
xcopy "Astro\Web" "%windir%\Web" /E /I /H /Y
rmdir /S /Q %windir%\Cursors
xcopy "Astro\Cursors" "%windir%\Cursors" /E /I /H /Y
rmdir /S /Q %windir%\Media
xcopy "Astro\Media" "%windir%\Media" /E /I /H /Y
del "%windir%\Branding\Basebrd\basebrd.dll"
copy "Astro\basebrd.dll" "%windir%\Branding\Basebrd"
del "%windir%\SystemResources\DDORes.dll.mun"
copy "Astro\DDORes.dll.mun" "%windir%\SystemResources"
del "%windir%\SystemResources\imageres.dll.mun"
copy "Astro\imageres.dll.mun" "%windir%\SystemResources"
del "%windir%\SystemResources\shell32.dll.mun"
copy "Astro\shell32.dll.mun" "%windir%\SystemResources"
startback.exe /SILENT

cd C:\Windows\Resources\Themes
del themeA.theme
del themeB.theme
del themeC.theme
del themeD.theme
del spotlight.theme

exit