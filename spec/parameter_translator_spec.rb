 require "yodlicious/parameter_translator"

describe 'parameter translator' do
  subject { Yodlicious::ParameterTranslator.new }
  context 'converting login params json to add site params' do
    let (:login_form) {
      {
        conjunctionOp: {  
          conjuctionOp: 1
        },
        componentList: [  
          {  
            valueIdentifier: 'LOGIN',
            valueMask: 'LOGIN_FIELD',
            fieldType: {  
              typeName: 'IF_LOGIN'
            },
            size: 20,
            maxlength: 32,
            name: 'LOGIN',
            displayName: 'User ID',
            isEditable: true,
            isOptional: false,
            isEscaped: false,
            helpText: 4710,
            isOptionalMFA: false,
            isMFA: false,
            value: 'kanyewest'
          },
          {  
            valueIdentifier: 'PASSWORD',
            valueMask: 'LOGIN_FIELD',
            fieldType: {  
              typeName: 'IF_PASSWORD'
            },
            size: 20,
            maxlength: 40,
            name: 'PASSWORD',
            displayName: 'Password',
            isEditable: true,
            isOptional: false,
            isEscaped: false,
            helpText: 11976,
            isOptionalMFA: false,
            isMFA: false,
            value: 'iLoveTheGrammys'
          }
        ],
        defaultHelpText: 324
      }
    }

    let (:add_site_params) {
      {
        "credentialFields.enclosedType"          => "com.yodlee.common.FieldInfoSingle",
        "credentialFields[0].displayName"        => "User ID",
        "credentialFields[0].fieldType.typeName" => "IF_LOGIN",
        "credentialFields[0].helpText"           => 4710,
        "credentialFields[0].maxlength"          => 32,
        "credentialFields[0].name"               => "LOGIN",
        "credentialFields[0].size"               => 20,
        "credentialFields[0].value"              => 'kanyewest',
        "credentialFields[0].valueIdentifier"    => "LOGIN",
        "credentialFields[0].valueMask"          => "LOGIN_FIELD",
        "credentialFields[0].isEditable"         => true,
        "credentialFields[1].displayName"        => "Password",
        "credentialFields[1].fieldType.typeName" => "IF_PASSWORD",
        "credentialFields[1].helpText"           => 11976,
        "credentialFields[1].maxlength"          => 40,
        "credentialFields[1].name"               => "PASSWORD",
        "credentialFields[1].size"               => 20,
        "credentialFields[1].value"              => 'iLoveTheGrammys',
        "credentialFields[1].valueIdentifier"    => "PASSWORD",
        "credentialFields[1].valueMask"          => "LOGIN_FIELD",
        "credentialFields[1].isEditable"         => true 
      }
    }

    it "converts correctly to params hash" do
      expect(subject.site_login_form_to_add_site_account_params(login_form)).to be == add_site_params
    end

  end
end