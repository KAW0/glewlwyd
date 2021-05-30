import React, { Component } from 'react';
import i18next from 'i18next';

import apiManager from '../lib/APIManager';
import messageDispatcher from '../lib/MessageDispatcher';
import Notification from '../lib/Notification';

class SchemeMock extends Component {
  constructor(props) {
    super(props);

    this.state = {
      config: props.config,
      module: props.module,
      name: props.name,
      profile: props.profile,
      schemePrefix: props.schemePrefix,
      registered: false,
      registration: false,
      forbidden: false
    };
    
    this.getRegister = this.getRegister.bind(this);
    this.register = this.register.bind(this);
    
    this.getRegister();
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      config: nextProps.config,
      module: nextProps.module,
      name: nextProps.name,
      profile: nextProps.profile,
      schemePrefix: nextProps.schemePrefix,
      registered: false,
      registration: false,
      forbidden: false
    }, () => {
      this.getRegister();
    });
  }
  
  getRegister() {
    if (this.state.profile) {
      apiManager.glewlwydRequest(this.state.schemePrefix+"/scheme/register/", "PUT", {username: this.state.profile.username, scheme_type: this.state.module, scheme_name: this.state.name}, true)
      .then((res) => {
        this.setState({registration: i18next.t("profile.scheme-mock-register-status-registered"), registered: true, forbidden: false});
      })
      .fail((err) => {
        if (err.status === 400) {
          this.setState({registration: i18next.t("profile.scheme-mock-register-status-not-registered"), registered: false, forbidden: false});
        } else if (err.status === 401) {
          messageDispatcher.sendMessage('App', {type: "loggedIn", loggedIn: false});
        } else if (err.status === 403) {
          this.setState({registration: i18next.t("profile.scheme-register-forbidden"), registered: false, forbidden: true});
        } else {
          messageDispatcher.sendMessage('Notification', {type: "danger", message: i18next.t("error-api-connect")});
        }
      });
    }
  }
  
  register() {
    apiManager.glewlwydRequest(this.state.schemePrefix+"/scheme/register/", "POST", {username: this.state.profile.username, scheme_type: this.state.module, scheme_name: this.state.name, value: {register: !this.state.registered}})
    .fail((err) => {
      if (err.status === 401) {
        messageDispatcher.sendMessage('App', {type: "loggedIn", loggedIn: false});
      } else {
        messageDispatcher.sendMessage('Notification', {type: "danger", message: i18next.t("error-api-connect")});
      }
    })
    .always(() => {
      messageDispatcher.sendMessage('App', {type: "registration"});
      this.getRegister();
    });
  }
  
	render() {
    var jsxRegistration, jsxButton;
    if (!this.state.forbidden) {
      jsxButton =
        <div className="row">
          <div className="col-md-12">
            <div className="btn-group" role="group">
              <button type="button" className="btn btn-primary" onClick={(e) => this.register(e)}>{this.state.registered?i18next.t("profile.scheme-mock-deregister"):i18next.t("profile.scheme-mock-register")}</button>
            </div>
          </div>
        </div>;
      if (this.state.registration) {
        jsxRegistration = <div><h4>{i18next.t("profile.scheme-mock-register-status")}</h4><span className="badge badge-primary">{this.state.registration}</span></div>;
      }
    } else {
      jsxRegistration = <div><h4>{i18next.t("profile.scheme-mock-register-status")}</h4><span className="badge badge-danger">{this.state.registration}</span></div>;
    }
    return (
      <div>
        <div className="row">
          <div className="col-md-12">
            <h4>{i18next.t("profile.scheme-mock-title", {module: this.state.module, name: this.state.name})}</h4>
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            {jsxRegistration}
          </div>
        </div>
        <div className="row">
          <div className="col-md-12">
            <hr/>
          </div>
        </div>
        {jsxButton}
      </div>
    );
  }
}

export default SchemeMock;
