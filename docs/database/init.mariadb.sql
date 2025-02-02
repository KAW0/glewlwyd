-- ------------------------------------------------------ --
--              Mariadb/Mysql Database                    --
-- Initialize Glewlwyd Database for the backend server    --
-- The administration client app                          --
-- Copyright 2020-2021 Nicolas Mora <mail@babelouest.org> --
-- License: MIT                                           --
-- ------------------------------------------------------ --

DROP TABLE IF EXISTS g_api_key;
DROP TABLE IF EXISTS g_client_user_scope;
DROP TABLE IF EXISTS g_scope_group_auth_scheme_module_instance;
DROP TABLE IF EXISTS g_scope_group;
DROP TABLE IF EXISTS g_user_session_scheme;
DROP TABLE IF EXISTS g_scope;
DROP TABLE IF EXISTS g_plugin_module_instance;
DROP TABLE IF EXISTS g_user_module_instance;
DROP TABLE IF EXISTS g_user_middleware_module_instance;
DROP TABLE IF EXISTS g_user_auth_scheme_module_instance;
DROP TABLE IF EXISTS g_client_module_instance;
DROP TABLE IF EXISTS g_user_session;
DROP TABLE IF EXISTS g_client_property;
DROP TABLE IF EXISTS g_client_scope_client;
DROP TABLE IF EXISTS g_client_scope;
DROP TABLE IF EXISTS g_client;
DROP TABLE IF EXISTS g_user_property;
DROP TABLE IF EXISTS g_user_scope_user;
DROP TABLE IF EXISTS g_user_scope;
DROP TABLE IF EXISTS g_user_password;
DROP TABLE IF EXISTS g_user;
DROP TABLE IF EXISTS gpg_device_authorization_scope;
DROP TABLE IF EXISTS gpg_device_authorization;
DROP TABLE IF EXISTS gpg_access_token_scope;
DROP TABLE IF EXISTS gpg_access_token;
DROP TABLE IF EXISTS gpg_refresh_token_scope;
DROP TABLE IF EXISTS gpg_refresh_token;
DROP TABLE IF EXISTS gpg_code_scope;
DROP TABLE IF EXISTS gpg_code;
DROP TABLE IF EXISTS gpo_ciba_scope;
DROP TABLE IF EXISTS gpo_ciba_scheme;
DROP TABLE IF EXISTS gpo_ciba;
DROP TABLE IF EXISTS gpo_par_scope;
DROP TABLE IF EXISTS gpo_par;
DROP TABLE IF EXISTS gpo_rar;
DROP TABLE IF EXISTS gpo_dpop;
DROP TABLE IF EXISTS gpo_device_scheme;
DROP TABLE IF EXISTS gpo_device_authorization_scope;
DROP TABLE IF EXISTS gpo_device_authorization;
DROP TABLE IF EXISTS gpo_client_registration;
DROP TABLE IF EXISTS gpo_subject_identifier;
DROP TABLE IF EXISTS gpo_id_token;
DROP TABLE IF EXISTS gpo_access_token_scope;
DROP TABLE IF EXISTS gpo_access_token;
DROP TABLE IF EXISTS gpo_refresh_token_scope;
DROP TABLE IF EXISTS gpo_refresh_token;
DROP TABLE IF EXISTS gpo_code_scheme;
DROP TABLE IF EXISTS gpo_code_scope;
DROP TABLE IF EXISTS gpo_code;
DROP TABLE IF EXISTS gpo_client_token_request;
DROP TABLE IF EXISTS gs_code;
DROP TABLE IF EXISTS gs_webauthn_assertion;
DROP TABLE IF EXISTS gs_webauthn_credential;
DROP TABLE IF EXISTS gs_webauthn_user;
DROP TABLE IF EXISTS gs_otp;
DROP TABLE IF EXISTS gs_user_certificate;
DROP TABLE IF EXISTS gpr_reset_credentials_email;
DROP TABLE IF EXISTS gpr_reset_credentials_session;
DROP TABLE IF EXISTS gpr_update_email;
DROP TABLE IF EXISTS gpr_session;
DROP TABLE IF EXISTS gs_oauth2_session;
DROP TABLE IF EXISTS gs_oauth2_registration;

CREATE TABLE g_user_module_instance (
  gumi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gumi_module VARCHAR(128) NOT NULL,
  gumi_order INT(11) NOT NULL,
  gumi_name VARCHAR(128) NOT NULL,
  gumi_display_name VARCHAR(256) DEFAULT '',
  gumi_parameters MEDIUMBLOB,
  gumi_readonly TINYINT(1) DEFAULT 0,
  gumi_multiple_passwords TINYINT(1) DEFAULT 0,
  gumi_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_user_middleware_module_instance (
  gummi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gummi_module VARCHAR(128) NOT NULL,
  gummi_order INT(11) NOT NULL,
  gummi_name VARCHAR(128) NOT NULL,
  gummi_display_name VARCHAR(256) DEFAULT '',
  gummi_parameters MEDIUMBLOB,
  gummi_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_user_auth_scheme_module_instance (
  guasmi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  guasmi_module VARCHAR(128) NOT NULL,
  guasmi_expiration INT(11) NOT NULL DEFAULT 0,
  guasmi_max_use INT(11) DEFAULT 0, -- 0: unlimited
  guasmi_allow_user_register TINYINT(1) DEFAULT 1,
  guasmi_forbid_user_profile TINYINT(1) DEFAULT 0,
  guasmi_forbid_user_reset_credential TINYINT(1) DEFAULT 0,
  guasmi_name VARCHAR(128) NOT NULL,
  guasmi_display_name VARCHAR(256) DEFAULT '',
  guasmi_parameters MEDIUMBLOB,
  guasmi_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_client_module_instance (
  gcmi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gcmi_module VARCHAR(128) NOT NULL,
  gcmi_order INT(11) NOT NULL,
  gcmi_name VARCHAR(128) NOT NULL,
  gcmi_display_name VARCHAR(256) DEFAULT '',
  gcmi_parameters MEDIUMBLOB,
  gcmi_readonly TINYINT(1) DEFAULT 0,
  gcmi_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_plugin_module_instance (
  gpmi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpmi_module VARCHAR(128) NOT NULL,
  gpmi_name VARCHAR(128) NOT NULL,
  gpmi_display_name VARCHAR(256) DEFAULT '',
  gpmi_parameters MEDIUMBLOB,
  gpmi_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_user_session (
  gus_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gus_session_hash VARCHAR(128) NOT NULL,
  gus_user_agent VARCHAR(256),
  gus_issued_for VARCHAR(256), -- IP address or hostname
  gus_username VARCHAR(256) NOT NULL,
  gus_expiration TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gus_last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gus_current TINYINT(1),
  gus_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_g_user_session_username ON g_user_session(gus_username);
CREATE INDEX i_g_user_session_last_login ON g_user_session(gus_last_login);
CREATE INDEX i_g_user_session_expiration ON g_user_session(gus_expiration);

CREATE TABLE g_user_session_scheme (
  guss_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gus_id INT(11) NOT NULL,
  guasmi_id INT(11) DEFAULT NULL, -- NULL means scheme 'password'
  guss_expiration TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guss_last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guss_use_counter INT(11) DEFAULT 0,
  guss_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gus_id) REFERENCES g_user_session(gus_id) ON DELETE CASCADE,
  FOREIGN KEY(guasmi_id) REFERENCES g_user_auth_scheme_module_instance(guasmi_id) ON DELETE CASCADE
);
CREATE INDEX i_g_user_session_scheme_last_login ON g_user_session_scheme(guss_last_login);
CREATE INDEX i_g_user_session_scheme_expiration ON g_user_session_scheme(guss_expiration);

CREATE TABLE g_scope (
  gs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gs_name VARCHAR(128) NOT NULL UNIQUE,
  gs_display_name VARCHAR(256) DEFAULT '',
  gs_description VARCHAR(512),
  gs_password_required TINYINT(1) DEFAULT 1,
  gs_password_max_age INT(11) DEFAULT 0,
  gs_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_scope_group (
  gsg_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gs_id INT(11),
  gsg_name VARCHAR(128) NOT NULL,
  gsg_scheme_required INT(11) DEFAULT 1,
  FOREIGN KEY(gs_id) REFERENCES g_scope(gs_id) ON DELETE CASCADE
);

CREATE TABLE g_scope_group_auth_scheme_module_instance (
  gsgasmi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gsg_id INT(11) NOT NULL,
  guasmi_id INT(11) NOT NULL,
  FOREIGN KEY(gsg_id) REFERENCES g_scope_group(gsg_id) ON DELETE CASCADE,
  FOREIGN KEY(guasmi_id) REFERENCES g_user_auth_scheme_module_instance(guasmi_id) ON DELETE CASCADE
);

CREATE TABLE g_client_user_scope (
  gcus_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gs_id INT(11) NOT NULL,
  gcus_username VARCHAR(256) NOT NULL,
  gcus_client_id VARCHAR(256) NOT NULL,
  gcus_granted TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gcus_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gs_id) REFERENCES g_scope(gs_id) ON DELETE CASCADE
);
CREATE INDEX i_g_client_user_scope_username ON g_client_user_scope(gcus_username);
CREATE INDEX i_g_client_user_scope_client_id ON g_client_user_scope(gcus_client_id);

CREATE TABLE g_api_key (
  gak_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gak_token_hash VARCHAR(512) NOT NULL,
  gak_counter INT(11) DEFAULT 0,
  gak_username VARCHAR(256) NOT NULL,
  gak_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gak_issued_for VARCHAR(256), -- IP address or hostname
  gak_user_agent VARCHAR(256),
  gak_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gak_token_hash ON g_api_key(gak_token_hash);

CREATE TABLE g_misc_config (
  gmc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gmc_type VARCHAR(128) NOT NULL,
  gmc_name VARCHAR(128),
  gmc_value MEDIUMBLOB
);
CREATE INDEX i_gmc_type ON g_misc_config(gmc_type);
CREATE INDEX i_gmc_name ON g_misc_config(gmc_name);

CREATE TABLE g_client (
  gc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gc_client_id VARCHAR(128) NOT NULL UNIQUE,
  gc_name VARCHAR(256) DEFAULT '',
  gc_description VARCHAR(512) DEFAULT '',
  gc_confidential TINYINT(1) DEFAULT 0,
  gc_password VARCHAR(256),
  gc_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_client_scope (
  gcs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gcs_name VARCHAR(128) NOT NULL UNIQUE
);

CREATE TABLE g_client_scope_client (
  gcsu_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gc_id INT(11),
  gcs_id INT(11),
  FOREIGN KEY(gc_id) REFERENCES g_client(gc_id) ON DELETE CASCADE,
  FOREIGN KEY(gcs_id) REFERENCES g_client_scope(gcs_id) ON DELETE CASCADE
);

CREATE TABLE g_client_property (
  gcp_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gc_id INT(11),
  gcp_name VARCHAR(128) NOT NULL,
  gcp_value_tiny VARCHAR(512) DEFAULT NULL,
  gcp_value_small BLOB DEFAULT NULL,
  gcp_value_medium MEDIUMBLOB DEFAULT NULL,
  FOREIGN KEY(gc_id) REFERENCES g_client(gc_id) ON DELETE CASCADE
);
CREATE INDEX i_g_client_property_name ON g_client_property(gcp_name);

CREATE TABLE g_user (
  gu_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gu_username VARCHAR(128) NOT NULL UNIQUE,
  gu_name VARCHAR(256) DEFAULT '',
  gu_email VARCHAR(512) DEFAULT '',
  gu_enabled TINYINT(1) DEFAULT 1
);

CREATE TABLE g_user_scope (
  gus_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gus_name VARCHAR(128) NOT NULL UNIQUE
);

CREATE TABLE g_user_scope_user (
  gusu_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gu_id INT(11),
  gus_id INT(11),
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE,
  FOREIGN KEY(gus_id) REFERENCES g_user_scope(gus_id) ON DELETE CASCADE
);

CREATE TABLE g_user_property (
  gup_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gu_id INT(11),
  gup_name VARCHAR(128) NOT NULL,
  gup_value_tiny VARCHAR(512) DEFAULT NULL,
  gup_value_small BLOB DEFAULT NULL,
  gup_value_medium MEDIUMBLOB DEFAULT NULL,
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE
);
CREATE INDEX i_g_user_property_name ON g_user_property(gup_name);

CREATE TABLE g_user_password (
  guw_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gu_id INT(11),
  guw_password VARCHAR(256),
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE
);

CREATE TABLE gpg_code (
  gpgc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgc_plugin_name VARCHAR(256) NOT NULL,
  gpgc_username VARCHAR(256) NOT NULL,
  gpgc_client_id VARCHAR(256) NOT NULL,
  gpgc_redirect_uri VARCHAR(512) NOT NULL,
  gpgc_code_hash VARCHAR(512) NOT NULL,
  gpgc_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgc_issued_for VARCHAR(256), -- IP address or hostname
  gpgc_user_agent VARCHAR(256),
  gpgc_code_challenge VARCHAR(128),
  gpgc_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gpgc_code_hash ON gpg_code(gpgc_code_hash);
CREATE INDEX i_gpgc_code_challenge ON gpg_code(gpgc_code_challenge);

CREATE TABLE gpg_code_scope (
  gpgcs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgc_id INT(11),
  gpgcs_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpgc_id) REFERENCES gpg_code(gpgc_id) ON DELETE CASCADE
);

CREATE TABLE gpg_refresh_token (
  gpgr_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgr_plugin_name VARCHAR(256) NOT NULL,
  gpgr_authorization_type INT(2) NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  gpgc_id INT(11) DEFAULT NULL,
  gpgr_username VARCHAR(256) NOT NULL,
  gpgr_client_id VARCHAR(256),
  gpgr_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_duration INT(11),
  gpgr_rolling_expiration TINYINT(1) DEFAULT 0,
  gpgr_issued_for VARCHAR(256), -- IP address or hostname
  gpgr_user_agent VARCHAR(256),
  gpgr_token_hash VARCHAR(512) NOT NULL,
  gpgr_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gpgc_id) REFERENCES gpg_code(gpgc_id) ON DELETE CASCADE
);
CREATE INDEX i_gpgr_token_hash ON gpg_refresh_token(gpgr_token_hash);

CREATE TABLE gpg_refresh_token_scope (
  gpgrs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgr_id INT(11),
  gpgrs_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpgr_id) REFERENCES gpg_refresh_token(gpgr_id) ON DELETE CASCADE
);

-- Access token table, to store meta information on access token sent
CREATE TABLE gpg_access_token (
  gpga_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpga_plugin_name VARCHAR(256) NOT NULL,
  gpga_authorization_type INT(2) NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  gpgr_id INT(11) DEFAULT NULL,
  gpga_username VARCHAR(256),
  gpga_client_id VARCHAR(256),
  gpga_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpga_issued_for VARCHAR(256), -- IP address or hostname
  gpga_user_agent VARCHAR(256),
  gpga_token_hash VARCHAR(512) NOT NULL,
  gpga_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gpgr_id) REFERENCES gpg_refresh_token(gpgr_id) ON DELETE CASCADE
);
CREATE INDEX i_gpga_token_hash ON gpg_access_token(gpga_token_hash);

CREATE TABLE gpg_access_token_scope (
  gpgas_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpga_id INT(11),
  gpgas_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpga_id) REFERENCES gpg_access_token(gpga_id) ON DELETE CASCADE
);

-- store device authorization requests
CREATE TABLE gpg_device_authorization (
  gpgda_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgda_plugin_name VARCHAR(256) NOT NULL,
  gpgda_client_id VARCHAR(256) NOT NULL,
  gpgda_username VARCHAR(256),
  gpgda_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpgda_expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpgda_issued_for VARCHAR(256), -- IP address or hostname of the device client
  gpgda_device_code_hash VARCHAR(512) NOT NULL,
  gpgda_user_code_hash VARCHAR(512) NOT NULL,
  gpgda_status TINYINT(1) DEFAULT 0, -- 0: created, 1: user verified, 2 device completed, 3 disabled
  gpgda_last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpgda_device_code_hash ON gpg_device_authorization(gpgda_device_code_hash);
CREATE INDEX i_gpgda_user_code_hash ON gpg_device_authorization(gpgda_user_code_hash);

CREATE TABLE gpg_device_authorization_scope (
  gpgdas_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpgda_id INT(11),
  gpgdas_scope VARCHAR(128) NOT NULL,
  gpgdas_allowed TINYINT(1) DEFAULT 0,
  FOREIGN KEY(gpgda_id) REFERENCES gpg_device_authorization(gpgda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_code (
  gpoc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoc_plugin_name VARCHAR(256) NOT NULL,
  gpoc_authorization_type INT(2) NOT NULL,
  gpoc_username VARCHAR(256) NOT NULL,
  gpoc_client_id VARCHAR(256) NOT NULL,
  gpoc_redirect_uri VARCHAR(512) NOT NULL,
  gpoc_code_hash VARCHAR(512) NOT NULL,
  gpoc_nonce VARCHAR(512),
  gpoc_resource VARCHAR(512),
  gpoc_claims_request BLOB DEFAULT NULL,
  gpoc_authorization_details BLOB DEFAULT NULL,
  gpoc_s_hash VARCHAR(512),
  gpoc_sid VARCHAR(128),
  gpoc_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpoc_issued_for VARCHAR(256), -- IP address or hostname
  gpoc_user_agent VARCHAR(256),
  gpoc_code_challenge VARCHAR(128),
  gpoc_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gpoc_code_hash ON gpo_code(gpoc_code_hash);
CREATE INDEX i_gpoc_code_challenge ON gpo_code(gpoc_code_challenge);

CREATE TABLE gpo_code_scope (
  gpocs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoc_id INT(11),
  gpocs_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);

CREATE TABLE gpo_code_scheme (
  gpoch_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoc_id INT(11),
  gpoch_scheme_module VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);

CREATE TABLE gpo_refresh_token (
  gpor_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpor_plugin_name VARCHAR(256) NOT NULL,
  gpor_authorization_type INT(2) NOT NULL,
  gpoc_id INT(11) DEFAULT NULL,
  gpor_username VARCHAR(256) NOT NULL,
  gpor_client_id VARCHAR(256),
  gpor_resource VARCHAR(512),
  gpor_claims_request BLOB DEFAULT NULL,
  gpor_authorization_details BLOB DEFAULT NULL,
  gpor_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_duration INT(11),
  gpor_rolling_expiration TINYINT(1) DEFAULT 0,
  gpor_issued_for VARCHAR(256), -- IP address or hostname
  gpor_user_agent VARCHAR(256),
  gpor_token_hash VARCHAR(512) NOT NULL,
  gpor_jti VARCHAR(128),
  gpor_dpop_jkt VARCHAR(512),
  gpor_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);
CREATE INDEX i_gpor_token_hash ON gpo_refresh_token(gpor_token_hash);
CREATE INDEX i_gpor_jti ON gpo_refresh_token(gpor_jti);

CREATE TABLE gpo_refresh_token_scope (
  gpors_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpor_id INT(11),
  gpors_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);

-- Access token table, to store meta information on access token sent
CREATE TABLE gpo_access_token (
  gpoa_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoa_plugin_name VARCHAR(256) NOT NULL,
  gpoa_authorization_type INT(2) NOT NULL,
  gpor_id INT(11) DEFAULT NULL,
  gpoa_username VARCHAR(256),
  gpoa_client_id VARCHAR(256),
  gpoa_resource VARCHAR(512),
  gpoa_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoa_issued_for VARCHAR(256), -- IP address or hostname
  gpoa_user_agent VARCHAR(256),
  gpoa_token_hash VARCHAR(512) NOT NULL,
  gpoa_jti VARCHAR(128),
  gpoa_authorization_details BLOB DEFAULT NULL,
  gpoa_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);
CREATE INDEX i_gpoa_token_hash ON gpo_access_token(gpoa_token_hash);
CREATE INDEX i_gpoa_jti ON gpo_access_token(gpoa_jti);

CREATE TABLE gpo_access_token_scope (
  gpoas_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoa_id INT(11),
  gpoas_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpoa_id) REFERENCES gpo_access_token(gpoa_id) ON DELETE CASCADE
);

-- Id token table, to store meta information on id token sent
CREATE TABLE gpo_id_token (
  gpoi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoc_id INT(11),
  gpor_id INT(11),
  gpoi_plugin_name VARCHAR(256) NOT NULL,
  gpoi_authorization_type INT(2) NOT NULL,
  gpoi_username VARCHAR(256),
  gpoi_client_id VARCHAR(256),
  gpoi_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoi_issued_for VARCHAR(256), -- IP address or hostname
  gpoi_user_agent VARCHAR(256),
  gpoi_hash VARCHAR(512),
  gpoi_sid VARCHAR(128),
  gpoi_enabled TINYINT(1) DEFAULT 1,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);
CREATE INDEX i_gpoi_hash ON gpo_id_token(gpoi_hash);

-- subject identifier table to store subs and their relations to usernames, client_id and sector_identifier
CREATE TABLE gpo_subject_identifier (
  gposi_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gposi_plugin_name VARCHAR(256) NOT NULL,
  gposi_username VARCHAR(256) NOT NULL,
  gposi_client_id VARCHAR(256),
  gposi_sector_identifier_uri VARCHAR(256),
  gposi_sub VARCHAR(256) NOT NULL
);
CREATE INDEX i_gposi_sub ON gpo_subject_identifier(gposi_sub);

-- store meta information on client registration
CREATE TABLE gpo_client_registration (
  gpocr_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpocr_plugin_name VARCHAR(256) NOT NULL,
  gpocr_cient_id VARCHAR(256) NOT NULL,
  gpocr_management_at_hash VARCHAR(512),
  gpocr_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoa_id INT(11),
  gpocr_issued_for VARCHAR(256), -- IP address or hostname
  gpocr_user_agent VARCHAR(256),
  FOREIGN KEY(gpoa_id) REFERENCES gpo_access_token(gpoa_id) ON DELETE CASCADE
);
CREATE INDEX i_gpocr_management_at_hash ON gpo_client_registration(gpocr_management_at_hash);

-- store meta information about client request on token endpoint
CREATE TABLE gpo_client_token_request (
  gpoctr_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoctr_plugin_name VARCHAR(256) NOT NULL,
  gpoctr_cient_id VARCHAR(256) NOT NULL,
  gpoctr_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoctr_issued_for VARCHAR(256), -- IP address or hostname
  gpoctr_jti_hash VARCHAR(512)
);

-- store device authorization requests
CREATE TABLE gpo_device_authorization (
  gpoda_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoda_plugin_name VARCHAR(256) NOT NULL,
  gpoda_client_id VARCHAR(256) NOT NULL,
  gpoda_resource VARCHAR(512),
  gpoda_username VARCHAR(256),
  gpoda_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoda_expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoda_issued_for VARCHAR(256), -- IP address or hostname of the device client
  gpoda_device_code_hash VARCHAR(512) NOT NULL,
  gpoda_user_code_hash VARCHAR(512) NOT NULL,
  gpoda_sid VARCHAR(128),
  gpoda_status TINYINT(1) DEFAULT 0, -- 0: created, 1: user verified, 2 device completed, 3 disabled
  gpoda_authorization_details BLOB DEFAULT NULL,
  gpoda_last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpoda_device_code_hash ON gpo_device_authorization(gpoda_device_code_hash);
CREATE INDEX i_gpoda_user_code_hash ON gpo_device_authorization(gpoda_user_code_hash);

CREATE TABLE gpo_device_authorization_scope (
  gpodas_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoda_id INT(11),
  gpodas_scope VARCHAR(128) NOT NULL,
  gpodas_allowed TINYINT(1) DEFAULT 0,
  FOREIGN KEY(gpoda_id) REFERENCES gpo_device_authorization(gpoda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_device_scheme (
  gpodh_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpoda_id INT(11),
  gpodh_scheme_module VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpoda_id) REFERENCES gpo_device_authorization(gpoda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_dpop (
  gpod_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpod_plugin_name VARCHAR(256) NOT NULL,
  gpod_client_id VARCHAR(256) NOT NULL,
  gpod_jti_hash VARCHAR(512) NOT NULL,
  gpod_jkt VARCHAR(512) NOT NULL,
  gpod_htm VARCHAR(128) NOT NULL,
  gpod_htu VARCHAR(512) NOT NULL,
  gpod_iat TIMESTAMP NOT NULL,
  gpod_last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpod_jti_hash ON gpo_dpop(gpod_jti_hash);

CREATE TABLE gpo_rar (
  gporar_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gporar_plugin_name VARCHAR(256) NOT NULL,
  gporar_client_id VARCHAR(256) NOT NULL,
  gporar_type VARCHAR(256) NOT NULL,
  gporar_username VARCHAR(256),
  gporar_consent TINYINT(1) DEFAULT 0,
  gporar_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gporar_client_id ON gpo_rar(gporar_client_id);
CREATE INDEX i_gporar_type ON gpo_rar(gporar_type);
CREATE INDEX i_gporar_username ON gpo_rar(gporar_username);

CREATE TABLE gpo_par (
  gpop_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpop_plugin_name VARCHAR(256) NOT NULL,
  gpop_response_type VARCHAR(128) NOT NULL,
  gpop_state BLOB,
  gpop_username VARCHAR(256),
  gpop_client_id VARCHAR(256) NOT NULL,
  gpop_redirect_uri VARCHAR(512) NOT NULL,
  gpop_request_uri_hash VARCHAR(512) NOT NULL,
  gpop_nonce VARCHAR(512),
  gpop_code_challenge VARCHAR(128),
  gpop_resource VARCHAR(512),
  gpop_claims_request BLOB DEFAULT NULL,
  gpop_authorization_details BLOB DEFAULT NULL,
  gpop_additional_parameters BLOB DEFAULT NULL,
  gpop_status TINYINT(1) DEFAULT 0, -- 0 created, 1 validated, 2 completed
  gpop_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpop_issued_for VARCHAR(256), -- IP address or hostname
  gpop_user_agent VARCHAR(256)
);
CREATE INDEX i_gpop_client_id ON gpo_par(gpop_client_id);
CREATE INDEX i_gpop_request_uri_hash ON gpo_par(gpop_request_uri_hash);
CREATE INDEX i_gpop_code_challenge ON gpo_par(gpop_code_challenge);

CREATE TABLE gpo_par_scope (
  gpops_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpop_id INT(11),
  gpops_scope VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpop_id) REFERENCES gpo_par(gpop_id) ON DELETE CASCADE
);

CREATE TABLE gpo_ciba (
  gpob_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpob_plugin_name VARCHAR(256) NOT NULL,
  gpob_client_id VARCHAR(256) NOT NULL,
  gpob_x5t_s256 VARCHAR(64),
  gpob_username VARCHAR(256) NOT NULL,
  gpob_client_notification_token VARCHAR(1024),
  gpob_jti_hash VARCHAR(512),
  gpob_auth_req_id VARCHAR(128),
  gpob_user_req_id VARCHAR(128),
  gpob_binding_message VARCHAR(256),
  gpob_sid VARCHAR(128),
  gpob_status TINYINT(1) DEFAULT 0, -- 0: created, 1: accepted, 2: error, 3: closed
  gpob_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpob_issued_for VARCHAR(256), -- IP address or hostname
  gpob_user_agent VARCHAR(256),
  gpob_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gpob_client_id ON gpo_ciba(gpob_client_id);
CREATE INDEX i_gpob_jti_hash ON gpo_ciba(gpob_jti_hash);
CREATE INDEX i_gpob_client_notification_token ON gpo_ciba(gpob_client_notification_token);
CREATE INDEX i_gpob_auth_req_id ON gpo_ciba(gpob_auth_req_id);
CREATE INDEX i_gpob_user_req_id ON gpo_ciba(gpob_user_req_id);

CREATE TABLE gpo_ciba_scope (
  gpocs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpob_id INT(11),
  gpops_scope VARCHAR(128) NOT NULL,
  gpobs_granted TINYINT(1) DEFAULT 0,
  FOREIGN KEY(gpob_id) REFERENCES gpo_ciba(gpob_id) ON DELETE CASCADE
);

CREATE TABLE gpo_ciba_scheme (
  gpobh_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gpob_id INT(11),
  gpobh_scheme_module VARCHAR(128) NOT NULL,
  FOREIGN KEY(gpob_id) REFERENCES gpo_ciba(gpob_id) ON DELETE CASCADE
);

CREATE TABLE gs_code (
  gsc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gsc_mod_name VARCHAR(128) NOT NULL,
  gsc_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsc_username VARCHAR(128) NOT NULL,
  gsc_enabled TINYINT(1) DEFAULT 1,
  gsc_code_hash VARCHAR(128),
  gsc_result TINYINT(1) DEFAULT 0
);
CREATE INDEX i_gssc_username ON gs_code(gsc_username);

CREATE TABLE gs_webauthn_user (
  gswu_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gswu_mod_name VARCHAR(128) NOT NULL,
  gswu_username VARCHAR(128) NOT NULL,
  gswu_user_id VARCHAR(128) NOT NULL
);
CREATE INDEX i_gswu_username ON gs_webauthn_user(gswu_username);

CREATE TABLE gs_webauthn_credential (
  gswc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gswu_id INT(11) NOT NULL,
  gswc_session_hash VARCHAR(128) NOT NULL,
  gswc_name VARCHAR(128),
  gswc_challenge_hash VARCHAR(128),
  gswc_credential_id VARCHAR(256),
  gswc_certificate VARCHAR(128),
  gswc_public_key TEXT DEFAULT NULL,
  gswc_counter INT(11) DEFAULT 0,
  gswc_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gswc_status TINYINT(1) DEFAULT 0, -- 0 new, 1 registered, 2 error, 3 disabled, 4 removed
  FOREIGN KEY(gswu_id) REFERENCES gs_webauthn_user(gswu_id) ON DELETE CASCADE
);
CREATE INDEX i_gswc_credential_id ON gs_webauthn_credential(gswc_credential_id);
CREATE INDEX i_gswc_session_hash ON gs_webauthn_credential(gswc_session_hash);

CREATE TABLE gs_webauthn_assertion (
  gswa_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gswu_id INT(11) NOT NULL,
  gswc_id INT(11),
  gswa_session_hash VARCHAR(128) NOT NULL,
  gswa_challenge_hash VARCHAR(128),
  gswa_counter INT(11) DEFAULT 0,
  gswa_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gswa_status TINYINT(1) DEFAULT 0, -- 0 new, 1 verified, 2 not verified, 3 error
  gswa_mock TINYINT(1) DEFAULT 0,
  FOREIGN KEY(gswu_id) REFERENCES gs_webauthn_user(gswu_id) ON DELETE CASCADE,
  FOREIGN KEY(gswc_id) REFERENCES gs_webauthn_credential(gswc_id) ON DELETE CASCADE
);
CREATE INDEX i_gswa_session_hash ON gs_webauthn_assertion(gswa_session_hash);

CREATE TABLE gs_otp (
  gso_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gso_mod_name VARCHAR(128) NOT NULL,
  gso_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gso_last_used TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gso_username VARCHAR(128) NOT NULL,
  gso_otp_type TINYINT(1) DEFAULT 0, -- 0 HOTP, 1 TOTP
  gso_secret VARCHAR(128) NOT NULL,
  gso_hotp_moving_factor INT(11),
  gso_totp_time_step_size INT(11)
);
CREATE INDEX i_gsso_username ON gs_otp(gso_username);

CREATE TABLE gs_user_certificate (
  gsuc_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gsuc_mod_name VARCHAR(128) NOT NULL,
  gsuc_username VARCHAR(128) NOT NULL,
  gsuc_enabled TINYINT(1) DEFAULT 1,
  gsuc_x509_certificate_content BLOB DEFAULT NULL,
  gsuc_x509_certificate_id VARCHAR(128) NOT NULL,
  gsuc_x509_certificate_dn VARCHAR(512) NOT NULL,
  gsuc_x509_certificate_issuer_dn VARCHAR(512) NOT NULL,
  gsuc_activation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsuc_expiration TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gsuc_last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gsuc_last_user_agent VARCHAR(512) DEFAULT NULL
);
CREATE INDEX i_gsuc_username ON gs_user_certificate(gsuc_username);
CREATE INDEX i_gsuc_x509_certificate_id ON gs_user_certificate(gsuc_x509_certificate_id);

CREATE TABLE gpr_session (
  gprs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gprs_plugin_name VARCHAR(256) NOT NULL,
  gprs_username VARCHAR(256) NOT NULL,
  gprs_name VARCHAR(512),
  gprs_email VARCHAR(512),
  gprs_code_hash VARCHAR(512),
  gprs_callback_url BLOB DEFAULT NULL,
  gprs_password_set TINYINT(1) DEFAULT 0,
  gprs_session_hash VARCHAR(512),
  gprs_token_hash VARCHAR(512),
  gprs_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprs_issued_for VARCHAR(256), -- IP address or hostname
  gprs_user_agent VARCHAR(256),
  gprs_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gprs_session_hash ON gpr_session(gprs_session_hash);
CREATE INDEX i_gprs_gprs_token_hash ON gpr_session(gprs_token_hash);
CREATE INDEX i_gprs_gprs_gprs_code_hash ON gpr_session(gprs_code_hash);

CREATE TABLE gpr_update_email (
  gprue_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gprue_plugin_name VARCHAR(256) NOT NULL,
  gprue_username VARCHAR(256) NOT NULL,
  gprue_email VARCHAR(512),
  gprue_token_hash VARCHAR(512),
  gprue_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprue_issued_for VARCHAR(256), -- IP address or hostname
  gprue_user_agent VARCHAR(256),
  gprue_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gprue_token_hash ON gpr_update_email(gprue_token_hash);

CREATE TABLE gpr_reset_credentials_session (
  gprrcs_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gprrcs_plugin_name VARCHAR(256) NOT NULL,
  gprrcs_username VARCHAR(256) NOT NULL,
  gprrcs_session_hash VARCHAR(512),
  gprrcs_callback_url BLOB DEFAULT NULL,
  gprrcs_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprrcs_issued_for VARCHAR(256), -- IP address or hostname
  gprrcs_user_agent VARCHAR(256),
  gprrcs_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gprrcs_session_hash ON gpr_reset_credentials_session(gprrcs_session_hash);

CREATE TABLE gpr_reset_credentials_email (
  gprrct_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gprrct_plugin_name VARCHAR(256) NOT NULL,
  gprrct_username VARCHAR(256) NOT NULL,
  gprrct_token_hash VARCHAR(512),
  gprrct_callback_url BLOB DEFAULT NULL,
  gprrct_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprrct_issued_for VARCHAR(256), -- IP address or hostname
  gprrct_user_agent VARCHAR(256),
  gprrct_enabled TINYINT(1) DEFAULT 1
);
CREATE INDEX i_gprrct_token_hash ON gpr_reset_credentials_email(gprrct_token_hash);

CREATE TABLE gs_oauth2_registration (
  gsor_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gsor_mod_name VARCHAR(128) NOT NULL,
  gsor_provider VARCHAR(128) NOT NULL,
  gsor_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsor_username VARCHAR(128) NOT NULL,
  gsor_userinfo_sub VARCHAR(128)
);
CREATE INDEX i_gsor_username ON gs_oauth2_registration(gsor_username);

CREATE TABLE gs_oauth2_session (
  gsos_id INT(11) PRIMARY KEY AUTO_INCREMENT,
  gsor_id INT(11),
  gsos_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsos_expires_at TIMESTAMP,
  gsos_state TEXT NOT NULL,
  gsos_session_export TEXT,
  gsos_status TINYINT(1) DEFAULT 0, -- 0: registration, 1: authentication, 2: verified, 3: cancelled
  FOREIGN KEY(gsor_id) REFERENCES gs_oauth2_registration(gsor_id) ON DELETE CASCADE
);

INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('g_admin', 'Glewlwyd administration', 'Access to Glewlwyd''s administration API', 1, 600);
INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('g_profile', 'Glewlwyd profile', 'Access to the user''s profile API', 1, 600);
INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('openid', 'Open ID', 'Open ID Connect scope', 0, 0);
INSERT INTO g_user_module_instance (gumi_module, gumi_order, gumi_name, gumi_display_name, gumi_parameters, gumi_readonly) VALUES ('database', 0, 'database', 'Database backend', '{"use-glewlwyd-connection":true,"data-format":{"picture":{"multiple":false,"read":true,"write":true,"profile-read":true,"profile-write":true},"reset-credentials-code":{"multiple":false,"read":true,"write":true,"profile-read":false,"profile-write":false}}}', 0);
INSERT INTO g_client_module_instance (gcmi_module, gcmi_order, gcmi_name, gcmi_display_name, gcmi_parameters, gcmi_readonly) VALUES ('database', 0, 'database', 'Database backend', '{"use-glewlwyd-connection":true,"data-format":{"redirect_uri":{"multiple":true,"read":true,"write":true},"authorization_type":{"multiple":true,"read":true,"write":true},"response_mode":{"multiple":false,"read":true,"write":true},"sector_identifier_uri":{"multiple":false,"read":true,"write":true},"token_endpoint_auth_method":{"multiple":true,"read":true,"write":true},"client_secret":{"multiple":false,"read":true,"write":true},"jwks":{"convert":"jwks","multiple":false,"read":true,"write":true},"jwks_uri":{"multiple":false,"read":true,"write":true},"pubkey":{"multiple":false,"read":true,"write":true},"enc":{"multiple":false,"read":true,"write":true},"alg":{"multiple":false,"read":true,"write":true},"alg_kid":{"multiple":false,"read":true,"write":true},"encrypt_code":{"multiple":false,"read":true,"write":true},"encrypt_at":{"multiple":false,"read":true,"write":true},"encrypt_userinfo":{"multiple":false,"read":true,"write":true},"encrypt_id_token":{"multiple":false,"read":true,"write":true},"encrypt_refresh_token":{"multiple":false,"read":true,"write":true},"resource":{"multiple":true,"read":true,"write":true},"authorization_data_types":{"multiple":true,"read":true,"write":true},"tls_client_auth_san_dns":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_uri":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_ip":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_email":{"multiple":false,"read":true,"write":true},"backchannel_token_delivery_mode":{"multiple":false,"read":true,"write":true},"backchannel_client_notification_endpoint":{"multiple":false,"read":true,"write":true},"backchannel_user_code_parameter":{"multiple":false,"read":true,"write":true},"request_object_signing_alg":{"multiple":false,"read":true,"write":true},"token_endpoint_signing_alg":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_signing_alg":{"multiple":false,"read":true,"write":true},"request_object_encryption_alg":{"multiple":false,"read":true,"write":true},"request_object_encryption_enc":{"multiple":false,"read":true,"write":true},"token_endpoint_encryption_alg":{"multiple":false,"read":true,"write":true},"token_endpoint_encryption_enc":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_encryption_alg":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_encryption_enc":{"multiple":false,"read":true,"write":true},"post_logout_redirect_uri":{"multiple":false,"read":true,"write":true},"frontchannel_logout_uri":{"multiple":false,"read":true,"write":true},"frontchannel_logout_session_required":{"multiple":false,"read":true,"write":true},"backchannel_logout_uri":{"multiple":false,"read":true,"write":true},"backchannel_logout_session_required":{"multiple":false,"read":true,"write":true}}}', 0);
INSERT INTO g_user (gu_username, gu_name, gu_email, gu_enabled) VALUES ('admin', 'The Administrator', '', 1);
INSERT INTO g_user_password (gu_id, guw_password) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), PASSWORD('password'));
INSERT INTO g_user_scope (gus_name) VALUES ('g_admin');
INSERT INTO g_user_scope (gus_name) VALUES ('g_profile');
INSERT INTO g_user_scope_user (gu_id, gus_id) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), (SELECT gus_id FROM g_user_scope WHERE gus_name='g_admin'));
INSERT INTO g_user_scope_user (gu_id, gus_id) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), (SELECT gus_id FROM g_user_scope WHERE gus_name='g_profile'));
