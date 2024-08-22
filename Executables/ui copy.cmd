:: Not working

rmdir /S /Q %windir%\Web
xcopy "Astro\Web" "%windir%\Web" /E /I /H /Y
del "%windir%\Branding\Basebrd\basebrd.dll"
xcopy "Astro\basebrd.dll" "%windir%\Branding\Basebrd\basebrd.dll" /E /I /H /Y
rmdir /S /Q %windir%\Cursors
xcopy "Astro\Cursors" "%windir%\Cursors" /E /I /H /Y
rmdir /S /Q %windir%\Media
xcopy "Astro\Media" "%windir%\Media" /E /I /H /Y
del "%windir%\SystemResources\DDORes.dll.mun"
xcopy "Astro\DDORes.dll.mun" "%windir%\SystemResources\DDORes.dll.mun" /E /I /H /Y
del "%windir%\SystemResources\imageres.dll.mun"
xcopy "Astro\imageres.dll.mun" "%windir%\SystemResources\imageres.dll.mun" /E /I /H /Y
del "%windir%\SystemResources\shell32.dll.mun"
xcopy "Astro\shell32.dll.mun" "%windir%\SystemResources\shell32.dll.mun" /E /I /H /Y

exit