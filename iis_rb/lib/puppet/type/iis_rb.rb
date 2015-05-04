Puppet::Type.newtype(:iis_rb) do
  @doc = "Windows IIS server"

  ensurable do
    desc "Windows IIS server"

    defaultvalues

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc ""
  end
 
  newparam(:dotnet) do
    desc ""
  end 
end
