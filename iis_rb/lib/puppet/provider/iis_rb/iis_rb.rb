Puppet::Type.type(:iis_rb).provide(:iis_rb) do
  @doc = "Manages Windows features for Windows 2008R2 and Windows 7"

  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  if Puppet.features.microsoft_windows?
    if ENV.has_key?('ProgramFiles(x86)')
      commands :dism => "#{Dir::WINDOWS}\\sysnative\\Dism.exe"
    else
      commands :dism => "#{Dir::WINDOWS}\\system32\\Dism.exe"
    end
	commands :powershell => "#{Dir::WINDOWS}\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
  end
 
  def create
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-WebServerRole", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-WebServer", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-ISAPIFilter", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-ISAPIExtensions", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-RequestFiltering", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-NetFxExtensibility", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:IIS-ASPNET", '/NoRestart'
		dism '/online', '/Enable-Feature', "/FeatureName:NetFx3", '/NoRestart'
		if resource[:dotnet] == "4.5"
			powershell '-NoProfile', '-executionpolicy remotesigned', '-command', '((new-object net.webclient).DownloadFile("http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe","$env:temp\dotNetFx45_Full_setup.exe")); & "$env:temp\dotNetFx45_Full_setup.exe" /q /noRestart'
		elsif resource[:dotnet] == "4.0"
			powershell '-NoProfile', '-executionpolicy remotesigned', '-command', '((new-object net.webclient).DownloadFile("http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe","$env:temp\dotNetFx40_Full_x86_x64.exe")); & "$env:temp\dotNetFx40_Full_x86_x64.exe" /q /noRestart'
		end
		powershell '-NoProfile', '-executionpolicy remotesigned', '-command', '((new-object net.webclient).DownloadFile("http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu","$env:temp\Windows6.1-KB2819745-x64-MultiPkg.msu")); & "$env:temp\Windows6.1-KB2819745-x64-MultiPkg.msu"  /quiet /norestart'
  end

  def destroy
    dism '/online', '/Disable-Feature', "/FeatureName:IIS-WebServerRole"
  end

  def currentstate(featurename)
    feature = dism '/online', '/Get-FeatureInfo', "/FeatureName:#{featurename}"
    feature =~ /^State : (\w+)/
    $1 
  end
  
  def dotnetstate
	inst = powershell '-NoProfile', "(reg query 'HKLM\\Software\\Microsoft\\NET Framework Setup\\NDP' /s /v version | select-string 'Version    REG_SZ    #{resource[:dotnet]}.*').length"
	if inst.to_i > 0
		return 'Enabled'
	else 
		return 'Disabled'
	end
  end

   def psversion
	ver = powershell '-NoProfile', '$host.version.major'
	if ver.to_i == 4
		return 'Enabled'
	else 
		return 'Disabled'
	end
  end 

  def exists?
	status = [currentstate("IIS-WebServerRole"), currentstate("IIS-WebServer"), currentstate("IIS-ISAPIFilter"), currentstate("IIS-ISAPIExtensions"), currentstate("IIS-RequestFiltering"), currentstate("IIS-NetFxExtensibility"), currentstate("IIS-ASPNET"), currentstate("NetFx3"), dotnetstate, psversion]
	status.all?{ |elem| elem ==  'Enabled'}
  end
end
