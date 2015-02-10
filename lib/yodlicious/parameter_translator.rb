module Yodlicious
  class ParameterTranslator
    def site_login_form_to_add_site_account_params site_login_form
      
      params = { "credentialFields.enclosedType" => "com.yodlee.common.FieldInfoSingle" }

      i = 0
      site_login_form[:componentList].each { |field|
        # puts "field=#{field}"
        params["credentialFields[#{i}].displayName"] = field[:displayName]
        params["credentialFields[#{i}].fieldType.typeName"] = field[:fieldType][:typeName]
        params["credentialFields[#{i}].helpText"] = field[:helpText]
        params["credentialFields[#{i}].maxlength"] = field[:maxlength]
        params["credentialFields[#{i}].name"] = field[:name]
        params["credentialFields[#{i}].size"] = field[:size]
        params["credentialFields[#{i}].value"] = field[:value]
        params["credentialFields[#{i}].valueIdentifier"] = field[:valueIdentifier]
        params["credentialFields[#{i}].valueMask"] = field[:valueMask]
        params["credentialFields[#{i}].isEditable"] = field[:isEditable]
        params["credentialFields[#{i}].value"] = field[:value]

        i += 1
      }

      params
    end
  end
end
