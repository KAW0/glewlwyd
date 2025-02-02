import React, { Component } from 'react';
import i18next from 'i18next';

import apiManager from '../lib/APIManager';
import ModEditParameters from './ModEditParameters';
import messageDispatcher from '../lib/MessageDispatcher';
import defaultParameters from '../lib/DefaultParameters';

let defaultParamClient = {
  "redirect_uri":{"multiple":true},
  "authorization_type":{"multiple":true},
  "response_mode":{"multiple":false},
  "sector_identifier_uri":{"multiple":false},
  "token_endpoint_auth_method":{"multiple":true},
  "client_secret":{"multiple":false},
  "jwks":{"convert":"jwks","multiple":false},
  "jwks_uri":{"multiple":false},
  "pubkey":{"multiple":false},
  "enc":{"multiple":false},
  "alg":{"multiple":false},
  "alg_kid":{"multiple":false},
  "encrypt_code":{"multiple":false},
  "encrypt_at":{"multiple":false},
  "encrypt_userinfo":{"multiple":false},
  "encrypt_id_token":{"multiple":false},
  "encrypt_refresh_token":{"multiple":false},
  "resource":{"multiple":true},
  "authorization_data_types":{"multiple":true},
  "tls_client_auth_san_dns":{"multiple":false},
  "tls_client_auth_san_uri":{"multiple":false},
  "tls_client_auth_san_ip":{"multiple":false},
  "tls_client_auth_san_email":{"multiple":false},
  "backchannel_token_delivery_mode":{"multiple":false},
  "backchannel_client_notification_endpoint":{"multiple":false},
  "backchannel_user_code_parameter":{"multiple":false},
  "request_object_signing_alg":{"multiple":false},
  "token_endpoint_signing_alg":{"multiple":false},
  "backchannel_authentication_request_signing_alg":{"multiple":false},
  "request_object_encryption_alg":{"multiple":false},
  "request_object_encryption_enc":{"multiple":false},
  "token_endpoint_encryption_alg":{"multiple":false},
  "token_endpoint_encryption_enc":{"multiple":false},
  "backchannel_authentication_request_encryption_alg":{"multiple":false},
  "backchannel_authentication_request_encryption_enc":{"multiple":false},
  "post_logout_redirect_uri":{"multiple":false},
  "frontchannel_logout_uri":{"multiple":false},
  "frontchannel_logout_session_required":{"multiple":false},
  "backchannel_logout_uri":{"multiple":false},
  "backchannel_logout_session_required":{"multiple":false}
};

let defaultParamUser = {
  "picture":{"multiple":false,"profile-read":true,"profile-write":true},
  "reset-credentials-code":{"multiple":false,"profile-read":false,"profile-write":false}
};

class ModEdit extends Component {
  constructor(props) {
    super(props);
    
    if (!props.mod) {
      props.mod = {};
    }
    
    if (!props.mod.expiration) {
      props.mod.expiration = 600;
    }
    
    if (!props.mod.max_use) {
      props.mod.max_use = 0;
    }

    if (props.mod.allow_user_register === undefined) {
      props.mod.allow_user_register = true;
    }
    
    if (props.role === "client") {
      if (props.mod.parameters["data-format"] === undefined) {
        props.mod.parameters["data-format"] = {};
      }
      defaultParameters.updateWithDefaultParameters(props.mod.parameters["data-format"], defaultParamClient);
    } else if (props.role === "user") {
      if (props.mod.parameters["data-format"] === undefined) {
        props.mod.parameters["data-format"] = {};
      }
      defaultParameters.updateWithDefaultParameters(props.mod.parameters["data-format"], defaultParamUser);
    }

    this.state = {
      config: props.config,
      title: props.title,
      mod: props.mod,
      role: props.role,
      modTypes: props.types,
      add: props.add,
      callback: props.callback,
      miscConfig: props.miscConfig,
      parametersValid: true,
      nameInvalid: false,
      nameInvalidMessage: false,
      typeInvalidMessage: false,
      check: false,
      hasError: false
    }
    
    messageDispatcher.subscribe('ModEdit', (message) => {
      if (message.type === 'modValid') {
        this.setState({check: false}, () => {
          if (this.state.add) {
            if (!this.state.mod.name) {
              this.setState({nameInvalid: true, nameInvalidMessage: i18next.t("admin.error-mod-name-mandatory"), typeInvalidMessage: false, hasError: true});
            } else if (!this.state.mod.module) {
              this.setState({nameInvalid: false, nameInvalidMessage: false, typeInvalidMessage: i18next.t("admin.error-mod-type-mandatory"), hasError: true});
            } else {
              apiManager.glewlwydRequest("/mod/" + this.state.role + "/" + encodeURIComponent(this.state.mod.name), "GET")
              .then(() => {
                this.setState({nameInvalid: true, nameInvalidMessage: i18next.t("admin.error-mod-name-exist"), typeInvalidMessage: false, hasError: true});
              })
              .fail((err) => {
                if (err.status === 404) {
                  this.state.callback(true, this.state.mod);
                }
              });
            }
          } else {
            this.state.callback(true, this.state.mod);
          }
        });
      } else if (message.type === 'modInvalid') {
        this.setState({check: false, hasError: true});
      }
    });

    this.closeModal = this.closeModal.bind(this);
    this.changeName = this.changeName.bind(this);
    this.changeDisplayName = this.changeDisplayName.bind(this);
    this.changeType = this.changeType.bind(this);
    this.toggleReadonly = this.toggleReadonly.bind(this);
    this.toggleAllowUserRegister = this.toggleAllowUserRegister.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    
    if (!nextProps.mod) {
      nextProps.mod = {};
    }
    
    if (!nextProps.mod.expiration) {
      nextProps.mod.expiration = 600;
    }
    
    if (!nextProps.mod.max_use) {
      nextProps.mod.max_use = 0;
    }

    if (nextProps.mod.allow_user_register === undefined) {
      nextProps.mod.allow_user_register = true;
    }

    if (nextProps.role === "client") {
      if (nextProps.mod.parameters["data-format"] === undefined) {
        nextProps.mod.parameters["data-format"] = {};
      }
      defaultParameters.updateWithDefaultParameters(nextProps.mod.parameters["data-format"], defaultParamClient);
    } else if (nextProps.role === "user") {
      if (nextProps.mod.parameters["data-format"] === undefined) {
        nextProps.mod.parameters["data-format"] = {};
      }
      defaultParameters.updateWithDefaultParameters(nextProps.mod.parameters["data-format"], defaultParamUser);
    }

    this.setState({
      config: nextProps.config,
      title: nextProps.title,
      mod: nextProps.mod,
      role: nextProps.role,
      modTypes: nextProps.types,
      add: nextProps.add,
      callback: nextProps.callback,
      miscConfig: nextProps.miscConfig,
      parametersValid: true,
      nameInvalid: false,
      nameInvalidMessage: false,
      typeInvalidMessage: false,
      hasError: false
    });
  }
    
  closeModal(e, result) {
    if (this.state.callback) {
      if (result) {
        this.setState({check: true});
      } else {
        this.state.callback(result);
      }
    }
  }
  
  changeName(e) {
    var mod = this.state.mod;
    mod.name = e.target.value;
    this.setState({mod: mod});
  }
  
  changeDisplayName(e) {
    var mod = this.state.mod;
    mod.display_name = e.target.value;
    this.setState({mod: mod});
  }
  
  changeType(e, name) {
    var mod = this.state.mod;
    mod.module = name;
    this.setState({mod: mod});
  }
  
  changeExpiration(e) {
    var mod = this.state.mod;
    mod.expiration = parseInt(e.target.value);
    this.setState({mod: mod});
  }
  
  changeMaxUse(e) {
    var mod = this.state.mod;
    mod.max_use = parseInt(e.target.value);
    this.setState({mod: mod});
  }
  
  toggleReadonly(e) {
    var mod = this.state.mod;
    mod.readonly = !mod.readonly;
    this.setState({mod: mod});
  }
  
  toggleMultiplePasswords(e) {
    var mod = this.state.mod;
    mod.multiple_passwords = !mod.multiple_passwords;
    this.setState({mod: mod});
  }
  
  toggleAllowUserRegister() {
    var mod = this.state.mod;
    mod.allow_user_register = !mod.allow_user_register;
    this.setState({mod: mod});
  }
  
  toggleForbidUserProfile() {
    var mod = this.state.mod;
    mod.forbid_user_profile = !mod.forbid_user_profile;
    this.setState({mod: mod});
  }
  
  toggleForbidUserResetCredential() {
    var mod = this.state.mod;
    mod.forbid_user_reset_credential = !mod.forbid_user_reset_credential;
    this.setState({mod: mod});
  }
  
	render() {
    var typeList = [];
    var modType;
    if (this.state.add) {
      var dropdownTitle = i18next.t("admin.mod-type-select");
      this.state.modTypes.forEach((mod, index) => {
        if (this.state.mod.module === mod.name) {
          dropdownTitle = mod.display_name;
          typeList.push(<a className="dropdown-item active" key={index} href="#" onClick={(e) => this.changeType(e, mod.name)}>{mod.display_name}</a>);
        } else {
          typeList.push(<a className="dropdown-item" key={index} href="#" onClick={(e) => this.changeType(e, mod.name)}>{mod.display_name}</a>);
        }
      });
      modType = <div className="dropdown">
        <button className="btn btn-secondary dropdown-toggle" type="button" id="dropdownModType" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          {dropdownTitle}
        </button>
        <div className="dropdown-menu" aria-labelledby="dropdownModType">
          {typeList}
        </div>
      </div>
    } else {
      this.state.modTypes.forEach((mod, index) => {
        if (this.state.mod.module === mod.name) {
          modType = <span className="badge badge-primary btn-icon-right">{mod.display_name}</span>
        }
      });
    }
    var hasError;
    if (this.state.hasError) {
      hasError = <span className="error-input text-right">{i18next.t("admin.error-input")}</span>;
    }
    var readonly = "", multiplePasswords = "";
    var schemeParams = "";
    if (this.state.role === "user") {
      var isChecked = !!this.state.mod.multiple_passwords;
      var isDisabled = false;
      if (this.state.mod.module==="http") {
        isChecked = false;
        isDisabled = true;
      }
      multiplePasswords = 
      <div className="form-group form-check">
        <input type="checkbox" className="form-check-input" id="mod-multiple-password" onChange={(e) => this.toggleMultiplePasswords(e)} checked={isChecked} disabled={isDisabled} />
        <label className="form-check-label" htmlFor="mod-multiple-password">{i18next.t("admin.mod-multiple-password")}</label>
      </div>;
    }
    if (this.state.role !== "scheme") {
      var isChecked = !!this.state.mod.readonly;
      var isDisabled = false;
      if (this.state.mod.module==="http") {
        isChecked = true;
        isDisabled = true;
      }
      readonly = 
      <div className="form-group form-check">
        <input type="checkbox" className="form-check-input" id="mod-readonly" onChange={(e) => this.toggleReadonly(e)} checked={isChecked} disabled={isDisabled} />
        <label className="form-check-label" htmlFor="mod-readonly">{i18next.t("admin.mod-readonly")}</label>
      </div>;
    } else {
      schemeParams = <div>
        <div className="form-group">
          <div className="input-group mb-3">
            <div className="input-group-prepend">
              <label className="input-group-text" htmlFor="mod-expiration">{i18next.t("admin.mod-expiration")}</label>
            </div>
            <input type="number" min="0" step="1" className="form-control" id="mod-expiration" placeholder={i18next.t("admin.mod-expiration-ph")} value={this.state.mod.expiration} onChange={(e) => this.changeExpiration(e)}/>
          </div>
        </div>
        <div className="form-group">
          <div className="input-group mb-3">
            <div className="input-group-prepend">
              <label className="input-group-text" htmlFor="mod-max-use">{i18next.t("admin.mod-max-use")}</label>
            </div>
            <input type="number" min="0" step="1" className="form-control" id="mod-max-use" placeholder={i18next.t("admin.mod-max-use-ph")} value={this.state.mod.max_use} onChange={(e) => this.changeMaxUse(e)}/>
          </div>
        </div>
        <div className="form-group form-check">
          <input type="checkbox" className="form-check-input" id="mod-forbid-user-profile" onChange={(e) => this.toggleForbidUserProfile(e)} checked={this.state.mod.forbid_user_profile||false} />
          <label className="form-check-label" htmlFor="mod-forbid-user-profile">{i18next.t("admin.mod-forbid-user-profile")}</label>
        </div>
        <div className="form-group form-check">
          <input type="checkbox" className="form-check-input" id="mod-forbid-user-reset-credential" onChange={(e) => this.toggleForbidUserResetCredential(e)} checked={this.state.mod.forbid_user_reset_credential||false} />
          <label className="form-check-label" htmlFor="mod-forbid-user-reset-credential">{i18next.t("admin.mod-forbid-user-reset-credential")}</label>
        </div>
        <div className="form-group form-check">
          <input type="checkbox" className="form-check-input" id="mod-allow-user-register" onChange={(e) => this.toggleAllowUserRegister(e)} checked={this.state.mod.allow_user_register} />
          <label className="form-check-label" htmlFor="mod-allow-user-register">{i18next.t("admin.mod-allow-user-register")}</label>
        </div>
      </div>
    }
		return (
    <div className="modal fade" id="editModModal" tabIndex="-1" role="dialog" aria-labelledby="confirmModalLabel" aria-hidden="true">
      <div className="modal-dialog modal-lg" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title" id="confirmModalLabel">{this.state.title}</h5>
            <button type="button" className="close" aria-label={i18next.t("modal.close")} onClick={(e) => this.closeModal(e, false)}>
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div className="modal-body">
            <form className="needs-validation" noValidate>
              <div className="form-group">
                <div className="input-group mb-3">
                  <div className="input-group-prepend">
                    <label className="input-group-text" htmlFor="mod-type">{i18next.t("admin.mod-type")}</label>
                  </div>
                  {modType}
                  <span className={"error-input" + (this.state.typeInvalidMessage?"":" hidden")}>{this.state.typeInvalidMessage}</span>
                </div>
              </div>
              <div className="form-group">
                <div className="input-group mb-3">
                  <div className="input-group-prepend">
                    <label className="input-group-text" htmlFor="mod-name">{i18next.t("admin.mod-name")}</label>
                  </div>
                  <input type="text" className={"form-control" + (this.state.nameInvalid?" is-invalid":"")} id="mod-name" placeholder={i18next.t("admin.mod-name-ph")} maxLength="128" value={this.state.mod.name||""} onChange={(e) => this.changeName(e)} disabled={!this.state.add} />
                  <span className={"error-input" + (this.state.nameInvalid?"":" hidden")}>{this.state.nameInvalidMessage}</span>
                </div>
              </div>
              <div className="form-group">
                <div className="input-group mb-3">
                  <div className="input-group-prepend">
                    <label className="input-group-text" htmlFor="mod-display-name">{i18next.t("admin.mod-display-name")}</label>
                  </div>
                  <input type="text" className="form-control" id="mod-display-name" placeholder={i18next.t("admin.mod-display-name-ph")} maxLength="256" value={this.state.mod.display_name||""} onChange={(e) => this.changeDisplayName(e)}/>
                </div>
              </div>
              {readonly}
              {multiplePasswords}
              {schemeParams}
              <ModEditParameters mod={this.state.mod} role={this.state.role} check={this.state.check} config={this.state.config} miscConfig={this.state.miscConfig} />
            </form>
          </div>
          <div className="modal-footer">
            {hasError}
            <button type="button" className="btn btn-secondary" onClick={(e) => this.closeModal(e, false)}>{i18next.t("modal.close")}</button>
            <button type="button" className="btn btn-primary" onClick={(e) => this.closeModal(e, true)}>{i18next.t("modal.ok")}</button>
          </div>
        </div>
      </div>
    </div>
		);
	}
}

export default ModEdit;
