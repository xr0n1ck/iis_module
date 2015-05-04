Sample of usage:

class iis_test {
	iis_rb { 'IIS':
		ensure => present,
		dotnet => "4.5",
	}
}