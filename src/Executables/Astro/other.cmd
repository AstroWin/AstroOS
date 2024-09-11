setlocal EnableDelayedExpansion
sc config WSearch start=disabled > nul
sc stop WSearch > nul 2>&1

for /f "usebackq" %%a in (`powershell -NonI -NoP -C "(Get-CimInstance Win32_NetworkAdapter).PNPDeviceID | sls 'PCI\\VEN_'"`) do (
	for /f "tokens=3" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%a" /v "Driver"') do ( 
        set "netKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b"
    ) > nul 2>&1
)


for %%a in (
    "AutoDisableGigabit"
    "ApCompatMode"
    "SipsEnabled"
    "ReduceSpeedOnPowerDown"
    "DMACoalescing"
) do (
    rem
    for /f %%b in ('reg query "%netKey%" /v "%%~a" ^| findstr "HKEY"') do (
        reg add "%netKey%" /v "%%~a" /t REG_SZ /d "0" /f > nul
    )
    rem
    for /f %%b in ('reg query "%netKey%" /v "*%%~a" ^| findstr "HKEY"') do (
        reg add "%netKey%" /v "*%%~a" /t REG_SZ /d "0" /f > nul
    )
) > nul 2>&1

copy /y "Layout.xml" "!userAppdata!\Microsoft\Windows\Shell\LayoutModification.xml" > nul

			if "%%a" neq "AME_UserHive_Default" (
				echo Clear Start Menu pinned items
				for /f "usebackq delims=" %%d in (`dir /b "!userAppdata!\Packages" /a:d ^| findstr /c:"Microsoft.Windows.StartMenuExperienceHost"`) do (
					for /f "usebackq delims=" %%e in (`dir /b "!userAppdata!\Packages\%%d\LocalState" /a:-d ^| findstr /R /c:"start.\.bin" /c:"start\.bin"`) do (
						del /q /f "!userAppdata!\Packages\%%d\LocalState\%%e" > nul 2>&1
					)
				)
			)

for /f "usebackq delims=" %%c in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" 2^>nul ^| findstr /c:"start.tilegrid" 2^>nul`) do (
			reg delete "%%c" /f > nul 2>&1
		)
		
		echo Removing advertisements/stubs from Start Menu ^(23H2+^)
		reg delete "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "Config" /f > nul 2>&1            




set "IPs=13.64.90.137 13.68.31.193 13.69.131.175 13.66.56.243 13.68.82.8 13.68.92.143 13.68.233.9 13.69.109.130 13.69.109.131 13.73.26.107 13.74.169.109 13.78.130.220 13.78.232.226 13.78.233.133 13.88.21.125 13.92.194.212 13.104.215.69 13.105.28.32 13.105.28.48 20.44.86.43 20.49.150.241 20.54.232.160 20.60.20.4 20.69.137.228 20.190.169.24 20.190.169.25 23.99.49.121 23.102.4.253 23.102.5.5 23.102.21.4 23.103.182.126 40.68.222.212 40.69.153.67 40.70.184.83 40.70.220.248 40.77.228.47 40.77.228.87 40.77.228.92 40.77.232.101 40.78.128.150 40.79.85.125 40.88.32.150 40.112.209.200 40.115.3.210 40.115.119.185 40.119.211.203 40.124.34.70 40.126.41.96 40.126.41.160 51.104.136.2 51.105.218.222 51.140.40.236 51.140.157.153 51.143.53.152 51.143.111.7 51.143.111.81 51.144.227.73 52.147.198.201 52.138.204.217 52.155.94.78 52.157.234.37 52.158.208.111 52.164.241.205 52.169.189.83 52.170.83.19 52.174.22.246 52.178.147.240 52.178.151.212 52.178.223.23 52.182.141.63 52.183.114.173 52.184.221.185 52.229.39.152 52.230.85.180 52.230.222.68 52.236.42.239 52.236.43.202 52.255.188.83 65.52.100.7 65.52.100.9 65.52.100.11 65.52.100.91 65.52.100.92 65.52.100.93 65.52.100.94 65.52.161.64 65.55.29.238 65.55.83.120 65.55.113.11 65.55.113.12 65.55.113.13 65.55.176.90 65.55.252.43 65.55.252.63 65.55.252.70 65.55.252.71 65.55.252.72 65.55.252.93 65.55.252.190 65.55.252.202 66.119.147.131 104.41.207.73 104.42.151.234 104.43.137.66 104.43.139.21 104.43.139.144 104.43.140.223 104.43.193.48 104.43.228.53 104.43.228.202 104.43.237.169 104.45.11.195 104.45.214.112 104.46.1.211 104.46.38.64 104.46.162.224 104.46.162.226 104.210.4.77 104.210.40.87 104.210.212.243 104.214.35.244 104.214.78.152 131.253.6.87 131.253.6.103 131.253.34.230 131.253.34.234 131.253.34.237 131.253.34.243 131.253.34.246 131.253.34.247 131.253.34.249 131.253.34.252 131.253.34.255 131.253.40.37 134.170.30.202 134.170.30.203 134.170.30.204 134.170.30.221 134.170.52.151 134.170.235.16 157.56.74.250 157.56.91.77 157.56.106.184 157.56.106.185 157.56.106.189 157.56.113.217 157.56.121.89 157.56.124.87 157.56.149.250 157.56.194.72 157.56.194.73 157.56.194.74 168.61.24.141 168.61.146.25 168.61.149.17 168.61.161.212 168.61.172.71 168.62.187.13 168.63.100.61 168.63.108.233 191.236.155.80 191.237.218.239 191.239.50.18 191.239.50.77 191.239.52.100 191.239.54.52 207.68.166.254"

for %%i in (%IPs%) do (
    netsh advfirewall firewall add rule name="Block IP %%i" dir=in action=block remoteip=%%i >NUL
    netsh advfirewall firewall add rule name="Block IP %%i" dir=out action=block remoteip=%%i >NUL
)

(
    echo.
    echo # Added by AstroOS
    echo.
    echo # MalwareInvestigation - start
    echo 0.0.0.0 acabstealer.ru
    echo 0.0.0.0 dieserbenni.ru
    echo 0.0.0.0 1312stealer.ru
    echo 0.0.0.0 1312services.ru
    echo 0.0.0.0 kleinanzeigen.ru
    echo 0.0.0.0 funcaptcha.ru
    echo 0.0.0.0 revengedrainer.com
    echo 0.0.0.0 cosmoplwnets.xyz
    # sus ips:
    echo 0.0.0.0 45.11.229.96
    echo 0.0.0.0 2.56.245.243
    echo.
    echo # MalwareInvestigation - end
    echo.
    echo # https://github.com/crazy-max
    echo 0.0.0.0 1oavsblobprodcus350.blob.core.windows.net 
    echo 0.0.0.0 37bvsblobprodcus311.blob.core.windows.net 
    echo 0.0.0.0 a.ads1.msn.com 
    echo 0.0.0.0 a.ads2.msads.net 
    echo 0.0.0.0 a.ads2.msn.com 
    echo 0.0.0.0 a.rad.msn.com 
    echo 0.0.0.0 ac3.msn.com 
    echo 0.0.0.0 adnexus.net 
    echo 0.0.0.0 adnxs.com 
    echo 0.0.0.0 ads.msn.com 
    echo 0.0.0.0 ads1.msads.net 
    echo 0.0.0.0 ads1.msn.com 
    echo 0.0.0.0 aidps.atdmt.com 
    echo 0.0.0.0 aka-cdn-ns.adtech.de 
    echo 0.0.0.0 alpha.telemetry.microsoft.com 
    echo 0.0.0.0 api.cortana.ai 
    echo 0.0.0.0 api.edgeoffer.microsoft.com 
    echo 0.0.0.0 asimov-win.settings.data.microsoft.com.akadns.net 
    echo 0.0.0.0 azwancan.trafficmanager.net 
    echo 0.0.0.0 b.ads1.msn.com 
    echo 0.0.0.0 b.ads2.msads.net 
    echo 0.0.0.0 b.rad.msn.com 
    echo 0.0.0.0 bingads.microsoft.com 
    echo 0.0.0.0 blobcollector.events.data.trafficmanager.net 
    echo 0.0.0.0 bn2-ris-ap-prod-atm.trafficmanager.net 
    echo 0.0.0.0 bn2-ris-prod-atm.trafficmanager.net 
    echo 0.0.0.0 bn2wns1.wns.windows.com 
    echo 0.0.0.0 bn3sch020010558.wns.windows.com 
    echo 0.0.0.0 bn3sch020010560.wns.windows.com 
    echo 0.0.0.0 bn3sch020010618.wns.windows.com 
    echo 0.0.0.0 bn3sch020010629.wns.windows.com 
    echo 0.0.0.0 bn3sch020010631.wns.windows.com 
    echo 0.0.0.0 bn3sch020010635.wns.windows.com 
    echo 0.0.0.0 bn3sch020010636.wns.windows.com 
    echo 0.0.0.0 bn3sch020010650.wns.windows.com 
    echo 0.0.0.0 bn3sch020011727.wns.windows.com 
    echo 0.0.0.0 bn3sch020012850.wns.windows.com 
    echo 0.0.0.0 bn3sch020020322.wns.windows.com 
    echo 0.0.0.0 bn3sch020020749.wns.windows.com 
    echo 0.0.0.0 bn3sch020022328.wns.windows.com 
    echo 0.0.0.0 bn3sch020022335.wns.windows.com 
    echo 0.0.0.0 bn3sch020022361.wns.windows.com 
    echo 0.0.0.0 bn4sch101120814.wns.windows.com 
    echo 0.0.0.0 bn4sch101120818.wns.windows.com 
    echo 0.0.0.0 bn4sch101120911.wns.windows.com 
    echo 0.0.0.0 bn4sch101120913.wns.windows.com 
    echo 0.0.0.0 bn4sch101121019.wns.windows.com 
    echo 0.0.0.0 bn4sch101121109.wns.windows.com 
    echo 0.0.0.0 bn4sch101121118.wns.windows.com 
    echo 0.0.0.0 bn4sch101121223.wns.windows.com 
    echo 0.0.0.0 bn4sch101121407.wns.windows.com 
    echo 0.0.0.0 bn4sch101121618.wns.windows.com 
    echo 0.0.0.0 bn4sch101121704.wns.windows.com 
    echo 0.0.0.0 bn4sch101121709.wns.windows.com 
    echo 0.0.0.0 bn4sch101121714.wns.windows.com 
    echo 0.0.0.0 bn4sch101121908.wns.windows.com 
    echo 0.0.0.0 bn4sch101122117.wns.windows.com 
    echo 0.0.0.0 bn4sch101122310.wns.windows.com 
    echo 0.0.0.0 bn4sch101122312.wns.windows.com 
    echo 0.0.0.0 bn4sch101122421.wns.windows.com 
    echo 0.0.0.0 bn4sch101123108.wns.windows.com 
    echo 0.0.0.0 bn4sch101123110.wns.windows.com 
    echo 0.0.0.0 bn4sch101123202.wns.windows.com 
    echo 0.0.0.0 bn4sch102110124.wns.windows.com 
    echo 0.0.0.0 browser.pipe.aria.microsoft.com 
    echo 0.0.0.0 bs.serving-sys.com 
    echo 0.0.0.0 c.atdmt.com 
    echo 0.0.0.0 c.msn.com 
    echo 0.0.0.0 ca.telemetry.microsoft.com 
    echo 0.0.0.0 cache.datamart.windows.com 
    echo 0.0.0.0 cdn.atdmt.com 
    echo 0.0.0.0 cds1.stn.llnw.net 
    echo 0.0.0.0 cds10.stn.llnw.net 
    echo 0.0.0.0 cds27.ory.llnw.net 
    echo 0.0.0.0 cds1203.lon.llnw.net 
    echo 0.0.0.0 cds1204.lon.llnw.net 
    echo 0.0.0.0 cds1209.lon.llnw.net 
    echo 0.0.0.0 cds1219.lon.llnw.net 
    echo 0.0.0.0 cds1228.lon.llnw.net 
    echo 0.0.0.0 cds1244.lon.llnw.net 
    echo 0.0.0.0 cds1257.lon.llnw.net 
    echo 0.0.0.0 cds1265.lon.llnw.net 
    echo 0.0.0.0 cds1269.lon.llnw.net 
    echo 0.0.0.0 cds1273.lon.llnw.net 
    echo 0.0.0.0 cds1285.lon.llnw.net 
    echo 0.0.0.0 cds1287.lon.llnw.net 
    echo 0.0.0.0 cds1289.lon.llnw.net 
    echo 0.0.0.0 cds1293.lon.llnw.net 
    echo 0.0.0.0 cds1307.lon.llnw.net 
    echo 0.0.0.0 cds1310.lon.llnw.net 
    echo 0.0.0.0 cds1325.lon.llnw.net 
    echo 0.0.0.0 cds1327.lon.llnw.net 
    echo 0.0.0.0 cds177.dus.llnw.net 
    echo 0.0.0.0 cds20005.stn.llnw.net 
    echo 0.0.0.0 cds20404.lcy.llnw.net 
    echo 0.0.0.0 cds20411.lcy.llnw.net 
    echo 0.0.0.0 cds20415.lcy.llnw.net 
    echo 0.0.0.0 cds20416.lcy.llnw.net 
    echo 0.0.0.0 cds20417.lcy.llnw.net 
    echo 0.0.0.0 cds20424.lcy.llnw.net 
    echo 0.0.0.0 cds20425.lcy.llnw.net 
    echo 0.0.0.0 cds20431.lcy.llnw.net 
    echo 0.0.0.0 cds20435.lcy.llnw.net 
    echo 0.0.0.0 cds20440.lcy.llnw.net 
    echo 0.0.0.0 cds20443.lcy.llnw.net 
    echo 0.0.0.0 cds20445.lcy.llnw.net 
    echo 0.0.0.0 cds20450.lcy.llnw.net 
    echo 0.0.0.0 cds20452.lcy.llnw.net 
    echo 0.0.0.0 cds20457.lcy.llnw.net 
    echo 0.0.0.0 cds20461.lcy.llnw.net 
    echo 0.0.0.0 cds20469.lcy.llnw.net 
    echo 0.0.0.0 cds20475.lcy.llnw.net 
    echo 0.0.0.0 cds20482.lcy.llnw.net 
    echo 0.0.0.0 cds20485.lcy.llnw.net 
    echo 0.0.0.0 cds20495.lcy.llnw.net 
    echo 0.0.0.0 cds21205.lon.llnw.net 
    echo 0.0.0.0 cds21207.lon.llnw.net 
    echo 0.0.0.0 cds21225.lon.llnw.net 
    echo 0.0.0.0 cds21229.lon.llnw.net 
    echo 0.0.0.0 cds21233.lon.llnw.net 
    echo 0.0.0.0 cds21238.lon.llnw.net 
    echo 0.0.0.0 cds21244.lon.llnw.net 
    echo 0.0.0.0 cds21249.lon.llnw.net 
    echo 0.0.0.0 cds21256.lon.llnw.net 
    echo 0.0.0.0 cds21257.lon.llnw.net 
    echo 0.0.0.0 cds21258.lon.llnw.net 
    echo 0.0.0.0 cds21261.lon.llnw.net 
    echo 0.0.0.0 cds21267.lon.llnw.net 
    echo 0.0.0.0 cds21278.lon.llnw.net 
    echo 0.0.0.0 cds21281.lon.llnw.net 
    echo 0.0.0.0 cds21293.lon.llnw.net 
    echo 0.0.0.0 cds21309.lon.llnw.net 
    echo 0.0.0.0 cds21313.lon.llnw.net 
    echo 0.0.0.0 cds21321.lon.llnw.net 
    echo 0.0.0.0 cds299.lcy.llnw.net 
    echo 0.0.0.0 cds308.lcy.llnw.net 
    echo 0.0.0.0 cds30027.stn.llnw.net 
    echo 0.0.0.0 cds310.lcy.llnw.net 
    echo 0.0.0.0 cds38.ory.llnw.net 
    echo 0.0.0.0 cds54.ory.llnw.net 
    echo 0.0.0.0 cds405.lcy.llnw.net 
    echo 0.0.0.0 cds406.lcy.llnw.net 
    echo 0.0.0.0 cds407.fra.llnw.net 
    echo 0.0.0.0 cds416.lcy.llnw.net 
    echo 0.0.0.0 cds421.lcy.llnw.net 
    echo 0.0.0.0 cds422.lcy.llnw.net 
    echo 0.0.0.0 cds425.lcy.llnw.net 
    echo 0.0.0.0 cds426.lcy.llnw.net 
    echo 0.0.0.0 cds447.lcy.llnw.net 
    echo 0.0.0.0 cds458.lcy.llnw.net 
    echo 0.0.0.0 cds459.lcy.llnw.net 
    echo 0.0.0.0 cds46.ory.llnw.net 
    echo 0.0.0.0 cds461.lcy.llnw.net 
    echo 0.0.0.0 cds468.lcy.llnw.net 
    echo 0.0.0.0 cds469.lcy.llnw.net 
    echo 0.0.0.0 cds471.lcy.llnw.net 
    echo 0.0.0.0 cds483.lcy.llnw.net 
    echo 0.0.0.0 cds484.lcy.llnw.net 
    echo 0.0.0.0 cds489.lcy.llnw.net 
    echo 0.0.0.0 cds493.lcy.llnw.net 
    echo 0.0.0.0 cds494.lcy.llnw.net 
    echo 0.0.0.0 cds812.lon.llnw.net 
    echo 0.0.0.0 cds815.lon.llnw.net 
    echo 0.0.0.0 cds818.lon.llnw.net 
    echo 0.0.0.0 cds832.lon.llnw.net 
    echo 0.0.0.0 cds836.lon.llnw.net 
    echo 0.0.0.0 cds840.lon.llnw.net 
    echo 0.0.0.0 cds843.lon.llnw.net 
    echo 0.0.0.0 cds857.lon.llnw.net 
    echo 0.0.0.0 cds868.lon.llnw.net 
    echo 0.0.0.0 cds869.lon.llnw.net 
    echo 0.0.0.0 ceuswatcab01.blob.core.windows.net 
    echo 0.0.0.0 ceuswatcab02.blob.core.windows.net 
    echo 0.0.0.0 compatexchange1.trafficmanager.net 
    echo 0.0.0.0 corp.sts.microsoft.com 
    echo 0.0.0.0 corpext.msitadfs.glbdns2.microsoft.com 
    echo 0.0.0.0 cs1.wpc.v0cdn.net 
    echo 0.0.0.0 cy2.vortex.data.microsoft.com.akadns.net 
    echo 0.0.0.0 db3aqu.atdmt.com 
    echo 0.0.0.0 db5.settings.data.microsoft.com.akadns.net 
    echo 0.0.0.0 db5.settings-win.data.microsoft.com.akadns.net 
    echo 0.0.0.0 db5.vortex.data.microsoft.com.akadns.net 
    echo 0.0.0.0 db5-eap.settings-win.data.microsoft.com.akadns.net 
    echo 0.0.0.0 df.telemetry.microsoft.com 
    echo 0.0.0.0 diagnostics.support.microsoft.com 
    echo 0.0.0.0 eaus2watcab01.blob.core.windows.net 
    echo 0.0.0.0 eaus2watcab02.blob.core.windows.net 
    echo 0.0.0.0 ec.atdmt.com 
    echo 0.0.0.0 flex.msn.com 
    echo 0.0.0.0 g.msn.com 
    echo 0.0.0.0 geo.settings.data.microsoft.com.akadns.net 
    echo 0.0.0.0 geo.settings-win.data.microsoft.com.akadns.net 
    echo 0.0.0.0 geo.vortex.data.microsoft.com.akadns.net 
    echo 0.0.0.0 h1.msn.com 
    echo 0.0.0.0 h2.msn.com 
    echo 0.0.0.0 hk2.settings.data.microsoft.com.akadns.net 
    echo 0.0.0.0 hk2.wns.windows.com 
    echo 0.0.0.0 hk2sch130020721.wns.windows.com 
    echo 0.0.0.0 hk2sch130020723.wns.windows.com 
    echo 0.0.0.0 hk2sch130020726.wns.windows.com 
    echo 0.0.0.0 hk2sch130020729.wns.windows.com 
    echo 0.0.0.0 hk2sch130020732.wns.windows.com 
    echo 0.0.0.0 hk2sch130020824.wns.windows.com 
    echo 0.0.0.0 hk2sch130020843.wns.windows.com 
    echo 0.0.0.0 hk2sch130020851.wns.windows.com 
    echo 0.0.0.0 hk2sch130020854.wns.windows.com 
    echo 0.0.0.0 hk2sch130020855.wns.windows.com 
    echo 0.0.0.0 hk2sch130020924.wns.windows.com 
    echo 0.0.0.0 hk2sch130020936.wns.windows.com 
    echo 0.0.0.0 hk2sch130020940.wns.windows.com 
    echo 0.0.0.0 hk2sch130020956.wns.windows.com 
    echo 0.0.0.0 hk2sch130020958.wns.windows.com 
    echo 0.0.0.0 hk2sch130020961.wns.windows.com 
    echo 0.0.0.0 hk2sch130021017.wns.windows.com 
    echo 0.0.0.0 hk2sch130021029.wns.windows.com 
    echo 0.0.0.0 hk2sch130021035.wns.windows.com 
    echo 0.0.0.0 hk2sch130021137.wns.windows.com 
    echo 0.0.0.0 hk2sch130021142.wns.windows.com 
    echo 0.0.0.0 hk2sch130021153.wns.windows.com 
    echo 0.0.0.0 hk2sch130021217.wns.windows.com 
    echo 0.0.0.0 hk2sch130021246.wns.windows.com 
    echo 0.0.0.0 hk2sch130021249.wns.windows.com 
    echo 0.0.0.0 hk2sch130021260.wns.windows.com 
    echo 0.0.0.0 hk2sch130021264.wns.windows.com 
    echo 0.0.0.0 hk2sch130021322.wns.windows.com 
    echo 0.0.0.0 hk2sch130021323.wns.windows.com 
    echo 0.0.0.0 hk2sch130021329.wns.windows.com 
    echo 0.0.0.0 hk2sch130021334.wns.windows.com 
    echo 0.0.0.0 hk2sch130021360.wns.windows.com 
    echo 0.0.0.0 hk2sch130021432.wns.windows.com 
    echo 0.0.0.0 hk2sch130021433.wns.windows.com 
    echo 0.0.0.0 hk2sch130021435.wns.windows.com 
    echo 0.0.0.0 hk2sch130021437.wns.windows.com 
    echo 0.0.0.0 hk2sch130021440.wns.windows.com 
    echo 0.0.0.0 hk2sch130021450.wns.windows.com 
    echo 0.0.0.0 hk2sch130021518.wns.windows.com 
    echo 0.0.0.0 hk2sch130021523.wns.windows.com 
    echo 0.0.0.0 hk2sch130021526.wns.windows.com 
    echo 0.0.0.0 hk2sch130021527.wns.windows.com 
    echo 0.0.0.0 hk2sch130021544.wns.windows.com 
    echo 0.0.0.0 hk2sch130021554.wns.windows.com 
    echo 0.0.0.0 hk2sch130021618.wns.windows.com 
    echo 0.0.0.0 hk2sch130021634.wns.windows.com 
    echo 0.0.0.0 hk2sch130021638.wns.windows.com 
    echo 0.0.0.0 hk2sch130021646.wns.windows.com 
    echo 0.0.0.0 hk2sch130021652.wns.windows.com 
    echo 0.0.0.0 hk2sch130021654.wns.windows.com 
    echo 0.0.0.0 hk2sch130021657.wns.windows.com 
    echo 0.0.0.0 hk2sch130021723.wns.windows.com 
    echo 0.0.0.0 hk2sch130021726.wns.windows.com 
    echo 0.0.0.0 hk2sch130021727.wns.windows.com 
    echo 0.0.0.0 hk2sch130021730.wns.windows.com 
    echo 0.0.0.0 hk2sch130021731.wns.windows.com 
    echo 0.0.0.0 hk2sch130021754.wns.windows.com 
    echo 0.0.0.0 hk2sch130021829.wns.windows.com 
    echo 0.0.0.0 hk2sch130021830.wns.windows.com 
    echo 0.0.0.0 hk2sch130021833.wns.windows.com 
    echo 0.0.0.0 hk2sch130021840.wns.windows.com 
    echo 0.0.0.0 hk2sch130021842.wns.windows.com 
    echo 0.0.0.0 hk2sch130021851.wns.windows.com 
    echo 0.0.0.0 hk2sch130021852.wns.windows.com 
    echo 0.0.0.0 hk2sch130021927.wns.windows.com 
    echo 0.0.0.0 hk2sch130021928.wns.windows.com 
    echo 0.0.0.0 hk2sch130021929.wns.windows.com 
    echo 0.0.0.0 hk2sch130021958.wns.windows.com 
    echo 0.0.0.0 hk2sch130022035.wns.windows.com 
    echo 0.0.0.0 hk2sch130022041.wns.windows.com 
    echo 0.0.0.0 hk2sch130022049.wns.windows.com 
    echo 0.0.0.0 hk2sch130022135.wns.windows.com 
    echo 0.0.0.0 hk2wns1.wns.windows.com 
    echo 0.0.0.0 hk2wns1b.wns.windows.com 
    echo 0.0.0.0 ieonlinews.microsoft.com 
    echo 0.0.0.0 ieonlinews.trafficmanager.net 
    echo 0.0.0.0 insideruser.trafficmanager.net 
    echo 0.0.0.0 kmwatson.events.data.microsoft.com 
    echo 0.0.0.0 kmwatsonc.events.data.microsoft.com 
    echo 0.0.0.0 lb1.www.ms.akadns.net 
    echo 0.0.0.0 live.rads.msn.com 
    echo 0.0.0.0 m.adnxs.com 
    echo 0.0.0.0 mobile.pipe.aria.microsoft.com 
    echo 0.0.0.0 modern.watson.data.microsoft.com.akadns.net 
    echo 0.0.0.0 msedge.net 
    echo 0.0.0.0 msntest.serving-sys.com 
    echo 0.0.0.0 nexus.officeapps.live.com 
    echo 0.0.0.0 nexusrules.officeapps.live.com 
    echo 0.0.0.0 nw-umwatson.events.data.microsoft.com 
    echo 0.0.0.0 oca.telemetry.microsoft.com 
    echo 0.0.0.0 oca.telemetry.microsoft.us 
    echo 0.0.0.0 onecollector.cloudapp.aria.akadns.net 
    echo 0.0.0.0 par02p.wns.windows.com 
    echo 0.0.0.0 pre.footprintpredict.com 
    echo 0.0.0.0 presence.teams.live.com 
    echo 0.0.0.0 preview.msn.com 
    echo 0.0.0.0 rad.live.com 
    echo 0.0.0.0 rad.msn.com 
    echo 0.0.0.0 redir.metaservices.microsoft.com 
    echo 0.0.0.0 reports.wes.df.telemetry.microsoft.com 
    echo 0.0.0.0 romeccs.microsoft.com 
    echo 0.0.0.0 schemas.microsoft.akadns.net 
    echo 0.0.0.0 secure.adnxs.com 
    echo 0.0.0.0 secure.flashtalking.com 
    echo 0.0.0.0 services.wes.df.telemetry.microsoft.com 
    echo 0.0.0.0 settings-sandbox.data.microsoft.com 
    echo 0.0.0.0 settings-win-ppe.data.microsoft.com 
    echo 0.0.0.0 settings.data.glbdns2.microsoft.com 
    echo 0.0.0.0 settingsfd-geo.trafficmanager.net 
    echo 0.0.0.0 sg2p.wns.windows.com 
    echo 0.0.0.0 spynet2.microsoft.com 
    echo 0.0.0.0 spynetalt.microsoft.com 
    echo 0.0.0.0 spyneteurope.microsoft.akadns.net 
    echo 0.0.0.0 sqm.df.telemetry.microsoft.com 
    echo 0.0.0.0 sqm.telemetry.microsoft.com 
    echo 0.0.0.0 sqm.telemetry.microsoft.com.nsatc.net 
    echo 0.0.0.0 ssw.live.com 
    echo 0.0.0.0 survey.watson.microsoft.com 
    echo 0.0.0.0 tele.trafficmanager.net 
    echo 0.0.0.0 telecommand.telemetry.microsoft.com 
    echo 0.0.0.0 telemetry.appex.bing.net 
    echo 0.0.0.0 telemetry.microsoft.com 
    echo 0.0.0.0 telemetry.remoteapp.windowsazure.com 
    echo 0.0.0.0 telemetry.urs.microsoft.com 
    echo 0.0.0.0 teredo.ipv6.microsoft.com 
    echo 0.0.0.0 test.activity.windows.com 
    echo 0.0.0.0 uks.b.prd.ags.trafficmanager.net 
    echo 0.0.0.0 umwatson.events.data.microsoft.com 
    echo 0.0.0.0 umwatsonc.events.data.microsoft.com 
    echo 0.0.0.0 umwatsonc.telemetry.microsoft.us 
    echo 0.0.0.0 v10.vortex-win.data.microsoft.com 
    echo 0.0.0.0 v10-win.vortex.data.microsoft.com.akadns.net 
    echo 0.0.0.0 v20.vortex-win.data.microsoft.com 
    echo 0.0.0.0 view.atdmt.com 
    echo 0.0.0.0 vortex-sandbox.data.microsoft.com 
    echo 0.0.0.0 vortex.data.glbdns2.microsoft.com 
    echo 0.0.0.0 vortex.data.microsoft.com 
    echo 0.0.0.0 watson.live.com 
    echo 0.0.0.0 watson.microsoft.com 
    echo 0.0.0.0 watson.ppe.telemetry.microsoft.com 
    echo 0.0.0.0 watson.telemetry.microsoft.com 
    echo 0.0.0.0 web.vortex.data.microsoft.com 
    echo 0.0.0.0 wes.df.telemetry.microsoft.com 
    echo 0.0.0.0 weus2watcab01.blob.core.windows.net 
    echo 0.0.0.0 weus2watcab02.blob.core.windows.net 
    echo 0.0.0.0 win10.ipv6.microsoft.com 
    echo 0.0.0.0 win1710.ipv6.microsoft.com 
    echo 0.0.0.0 win8.ipv6.microsoft.com 
    echo 0.0.0.0 xblgdvrassets3010.blob.core.windows.net 
    echo 0.0.0.0 ztd.dds.microsoft.com
    echo .
    echo # AstroOS
    echo # Visual Studio / Code
    echo 0.0.0.0 vortex.data.microsoft.com
    echo 0.0.0.0 dc.services.visualstudio.com
    echo 0.0.0.0 visualstudio-devdiv-c2s.msedge.net
    echo 0.0.0.0 az667904.vo.msecnd.net
    echo 0.0.0.0 scus-breeziest-in.cloudapp.net
    echo 0.0.0.0 nw-umwatson.events.data.microsoft.com
    echo 0.0.0.0 mobile.events.data.microsoft.com
    echo .
    echo # AstroOS
    echo # Brave Browser
    echo 0.0.0.0 p3a.brave.com
    echo 0.0.0.0 p2a.brave.com
    echo 0.0.0.0 p3a-json.brave.com
    echo 0.0.0.0 p2a-json.brave.com
    echo 0.0.0.0 cr.brave.com
) >> "%systemroot%\system32\drivers\etc\hosts"
