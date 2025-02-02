-- ------------------------------------------------------ --
--                 SQlite3 Database                       --
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
  gumi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gumi_module TEXT NOT NULL,
  gumi_order INTEGER NOT NULL,
  gumi_name TEXT NOT NULL,
  gumi_display_name TEXT DEFAULT '',
  gumi_parameters TEXT,
  gumi_readonly INTEGER DEFAULT 0,
  gumi_multiple_passwords INTEGER DEFAULT 0,
  gumi_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_user_middleware_module_instance (
  gummi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gummi_module TEXT NOT NULL,
  gummi_order INTEGER NOT NULL,
  gummi_name TEXT NOT NULL,
  gummi_display_name TEXT DEFAULT '',
  gummi_parameters TEXT,
  gummi_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_user_auth_scheme_module_instance (
  guasmi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  guasmi_module TEXT NOT NULL,
  guasmi_expiration INTEGER NOT NULL DEFAULT 0,
  guasmi_max_use INTEGER DEFAULT 0, -- 0: unlimited
  guasmi_allow_user_register INTEGER DEFAULT 1,
  guasmi_forbid_user_profile INTEGER DEFAULT 0,
  guasmi_forbid_user_reset_credential INTEGER DEFAULT 0,
  guasmi_name TEXT NOT NULL,
  guasmi_display_name TEXT DEFAULT '',
  guasmi_parameters TEXT,
  guasmi_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_client_module_instance (
  gcmi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gcmi_module TEXT NOT NULL,
  gcmi_order INTEGER NOT NULL,
  gcmi_name TEXT NOT NULL,
  gcmi_display_name TEXT DEFAULT '',
  gcmi_parameters TEXT,
  gcmi_readonly INTEGER DEFAULT 0,
  gcmi_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_plugin_module_instance (
  gpmi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpmi_module TEXT NOT NULL,
  gpmi_name TEXT NOT NULL,
  gpmi_display_name TEXT DEFAULT '',
  gpmi_parameters TEXT,
  gpmi_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_user_session (
  gus_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gus_session_hash TEXT NOT NULL,
  gus_user_agent TEXT,
  gus_issued_for TEXT, -- IP address or hostname
  gus_username TEXT NOT NULL,
  gus_expiration TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gus_last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gus_current INTEGER,
  gus_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_g_user_session_username ON g_user_session(gus_username);
CREATE INDEX i_g_user_session_last_login ON g_user_session(gus_last_login);
CREATE INDEX i_g_user_session_expiration ON g_user_session(gus_expiration);

CREATE TABLE g_user_session_scheme (
  guss_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gus_id INTEGER NOT NULL,
  guasmi_id INTEGER DEFAULT NULL, -- NULL means scheme 'password'
  guss_expiration TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guss_last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guss_use_counter INTEGER DEFAULT 0,
  guss_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gus_id) REFERENCES g_user_session(gus_id) ON DELETE CASCADE,
  FOREIGN KEY(guasmi_id) REFERENCES g_user_auth_scheme_module_instance(guasmi_id) ON DELETE CASCADE
);
CREATE INDEX i_g_user_session_scheme_last_login ON g_user_session_scheme(guss_last_login);
CREATE INDEX i_g_user_session_scheme_expiration ON g_user_session_scheme(guss_expiration);

CREATE TABLE g_scope (
  gs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gs_name TEXT NOT NULL UNIQUE,
  gs_display_name TEXT DEFAULT '',
  gs_description TEXT,
  gs_password_required INTEGER DEFAULT 1,
  gs_password_max_age INTEGER DEFAULT 0,
  gs_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_scope_group (
  gsg_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gs_id INTEGER,
  gsg_name TEXT NOT NULL,
  gsg_scheme_required INTEGER DEFAULT 1,
  FOREIGN KEY(gs_id) REFERENCES g_scope(gs_id) ON DELETE CASCADE
);

CREATE TABLE g_scope_group_auth_scheme_module_instance (
  gsgasmi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gsg_id INTEGER NOT NULL,
  guasmi_id INTEGER NOT NULL,
  FOREIGN KEY(gsg_id) REFERENCES g_scope_group(gsg_id) ON DELETE CASCADE,
  FOREIGN KEY(guasmi_id) REFERENCES g_user_auth_scheme_module_instance(guasmi_id) ON DELETE CASCADE
);

CREATE TABLE g_client_user_scope (
  gcus_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gs_id INTEGER NOT NULL,
  gcus_username TEXT NOT NULL,
  gcus_client_id TEXT NOT NULL,
  gcus_granted TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gcus_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gs_id) REFERENCES g_scope(gs_id) ON DELETE CASCADE
);
CREATE INDEX i_g_client_user_scope_username ON g_client_user_scope(gcus_username);
CREATE INDEX i_g_client_user_scope_client_id ON g_client_user_scope(gcus_client_id);

CREATE TABLE g_api_key (
  gak_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gak_token_hash TEXT NOT NULL,
  gak_counter INTEGER DEFAULT 0,
  gak_username TEXT NOT NULL,
  gak_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gak_issued_for TEXT, -- IP address or hostname
  gak_user_agent TEXT,
  gak_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gak_token_hash ON g_api_key(gak_token_hash);

CREATE TABLE g_misc_config (
  gmc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gmc_type TEXT NOT NULL,
  gmc_name TEXT,
  gmc_value TEXT
);
CREATE INDEX i_gmc_type ON g_misc_config(gmc_type);
CREATE INDEX i_gmc_name ON g_misc_config(gmc_name);

CREATE TABLE g_client (
  gc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gc_client_id TEXT NOT NULL UNIQUE,
  gc_name TEXT DEFAULT '',
  gc_description TEXT DEFAULT '',
  gc_confidential INTEGER DEFAULT 0,
  gc_password TEXT,
  gc_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_client_scope (
  gcs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gcs_name TEXT NOT NULL UNIQUE
);

CREATE TABLE g_client_scope_client (
  gcsu_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gc_id INTEGER,
  gcs_id INTEGER,
  FOREIGN KEY(gc_id) REFERENCES g_client(gc_id) ON DELETE CASCADE,
  FOREIGN KEY(gcs_id) REFERENCES g_client_scope(gcs_id) ON DELETE CASCADE
);

CREATE TABLE g_client_property (
  gcp_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gc_id INTEGER,
  gcp_name TEXT NOT NULL,
  gcp_value TEXT DEFAULT NULL,
  FOREIGN KEY(gc_id) REFERENCES g_client(gc_id) ON DELETE CASCADE
);
CREATE INDEX i_g_client_property_name ON g_client_property(gcp_name);

CREATE TABLE g_user (
  gu_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gu_username TEXT NOT NULL UNIQUE,
  gu_name TEXT DEFAULT '',
  gu_email TEXT DEFAULT '',
  gu_enabled INTEGER DEFAULT 1
);

CREATE TABLE g_user_scope (
  gus_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gus_name TEXT NOT NULL UNIQUE
);

CREATE TABLE g_user_scope_user (
  gusu_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gu_id INTEGER,
  gus_id INTEGER,
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE,
  FOREIGN KEY(gus_id) REFERENCES g_user_scope(gus_id) ON DELETE CASCADE
);

CREATE TABLE g_user_property (
  gup_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gu_id INTEGER,
  gup_name TEXT NOT NULL,
  gup_value TEXT DEFAULT NULL,
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE
);
CREATE INDEX i_g_user_property_name ON g_user_property(gup_name);

CREATE TABLE g_user_password (
  guw_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gu_id INTEGER,
  guw_password TEXT,
  FOREIGN KEY(gu_id) REFERENCES g_user(gu_id) ON DELETE CASCADE
);

CREATE TABLE gpg_code (
  gpgc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgc_plugin_name TEXT NOT NULL,
  gpgc_username TEXT NOT NULL,
  gpgc_client_id TEXT NOT NULL,
  gpgc_redirect_uri TEXT NOT NULL,
  gpgc_code_hash TEXT NOT NULL,
  gpgc_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgc_issued_for TEXT, -- IP address or hostname
  gpgc_user_agent TEXT,
  gpgc_code_challenge TEXT,
  gpgc_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gpgc_code_hash ON gpg_code(gpgc_code_hash);
CREATE INDEX i_gpgc_code_challenge ON gpg_code(gpgc_code_challenge);

CREATE TABLE gpg_code_scope (
  gpgcs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgc_id INTEGER,
  gpgcs_scope TEXT NOT NULL,
  FOREIGN KEY(gpgc_id) REFERENCES gpg_code(gpgc_id) ON DELETE CASCADE
);

CREATE TABLE gpg_refresh_token (
  gpgr_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgr_plugin_name TEXT NOT NULL,
  gpgr_authorization_type INTEGER NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  gpgc_id INTEGER DEFAULT NULL,
  gpgr_username TEXT NOT NULL,
  gpgr_client_id TEXT,
  gpgr_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpgr_duration INTEGER,
  gpgr_rolling_expiration INTEGER DEFAULT 0,
  gpgr_issued_for TEXT, -- IP address or hostname
  gpgr_user_agent TEXT,
  gpgr_token_hash TEXT NOT NULL,
  gpgr_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gpgc_id) REFERENCES gpg_code(gpgc_id) ON DELETE CASCADE
);
CREATE INDEX i_gpgr_token_hash ON gpg_refresh_token(gpgr_token_hash);

CREATE TABLE gpg_refresh_token_scope (
  gpgrs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgr_id INTEGER,
  gpgrs_scope TEXT NOT NULL,
  FOREIGN KEY(gpgr_id) REFERENCES gpg_refresh_token(gpgr_id) ON DELETE CASCADE
);

-- Access token table, to store meta information on access token sent
CREATE TABLE gpg_access_token (
  gpga_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpga_plugin_name TEXT NOT NULL,
  gpga_authorization_type INTEGER NOT NULL, -- 0: Authorization Code Grant, 1: Implicit Grant, 2: Resource Owner Password Credentials Grant, 3: Client Credentials Grant
  gpgr_id INTEGER DEFAULT NULL,
  gpga_username TEXT,
  gpga_client_id TEXT,
  gpga_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpga_issued_for TEXT, -- IP address or hostname
  gpga_user_agent TEXT,
  gpga_token_hash TEXT NOT NULL,
  gpga_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gpgr_id) REFERENCES gpg_refresh_token(gpgr_id) ON DELETE CASCADE
);
CREATE INDEX i_gpga_token_hash ON gpg_access_token(gpga_token_hash);

CREATE TABLE gpg_access_token_scope (
  gpgas_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpga_id INT(11),
  gpgas_scope TEXT NOT NULL,
  FOREIGN KEY(gpga_id) REFERENCES gpg_access_token(gpga_id) ON DELETE CASCADE
);

-- store device authorization requests
CREATE TABLE gpg_device_authorization (
  gpgda_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgda_plugin_name TEXT NOT NULL,
  gpgda_client_id TEXT NOT NULL,
  gpgda_username TEXT,
  gpgda_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpgda_expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpgda_issued_for TEXT, -- IP address or hostname of the device client
  gpgda_device_code_hash TEXT NOT NULL,
  gpgda_user_code_hash TEXT NOT NULL,
  gpgda_status INTEGER DEFAULT 0, -- 0: created, 1: user verified, 2 device completed, 3 disabled
  gpgda_last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpgda_device_code_hash ON gpg_device_authorization(gpgda_device_code_hash);
CREATE INDEX i_gpgda_user_code_hash ON gpg_device_authorization(gpgda_user_code_hash);

CREATE TABLE gpg_device_authorization_scope (
  gpgdas_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpgda_id INTEGER,
  gpgdas_scope TEXT NOT NULL,
  gpgdas_allowed INTEGER DEFAULT 0,
  FOREIGN KEY(gpgda_id) REFERENCES gpg_device_authorization(gpgda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_code (
  gpoc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoc_plugin_name TEXT NOT NULL,
  gpoc_authorization_type INTEGER NOT NULL,
  gpoc_username TEXT NOT NULL,
  gpoc_client_id TEXT NOT NULL,
  gpoc_redirect_uri TEXT NOT NULL,
  gpoc_code_hash TEXT NOT NULL,
  gpoc_nonce TEXT,
  gpoc_resource TEXT,
  gpoc_claims_request TEXT DEFAULT NULL,
  gpoc_authorization_details TEXT DEFAULT NULL,
  gpoc_s_hash TEXT,
  gpoc_sid TEXT,
  gpoc_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpoc_issued_for TEXT, -- IP address or hostname
  gpoc_user_agent TEXT,
  gpoc_code_challenge TEXT,
  gpoc_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gpoc_code_hash ON gpo_code(gpoc_code_hash);
CREATE INDEX i_gpoc_code_challenge ON gpo_code(gpoc_code_challenge);

CREATE TABLE gpo_code_scope (
  gpocs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoc_id INTEGER,
  gpocs_scope TEXT NOT NULL,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);

CREATE TABLE gpo_code_scheme (
  gpoch_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoc_id INTEGER,
  gpoch_scheme_module TEXT NOT NULL,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);

CREATE TABLE gpo_refresh_token (
  gpor_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpor_plugin_name TEXT NOT NULL,
  gpor_authorization_type INTEGER NOT NULL,
  gpoc_id INTEGER DEFAULT NULL,
  gpor_username TEXT NOT NULL,
  gpor_client_id TEXT,
  gpor_resource TEXT,
  gpor_claims_request TEXT DEFAULT NULL,
  gpor_authorization_details TEXT DEFAULT NULL,
  gpor_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpor_duration INTEGER,
  gpor_rolling_expiration INTEGER DEFAULT 0,
  gpor_issued_for TEXT, -- IP address or hostname
  gpor_user_agent TEXT,
  gpor_token_hash TEXT NOT NULL,
  gpor_jti TEXT,
  gpor_dpop_jkt TEXT,
  gpor_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE
);
CREATE INDEX i_gpor_token_hash ON gpo_refresh_token(gpor_token_hash);
CREATE INDEX i_gpor_jti ON gpo_refresh_token(gpor_jti);

CREATE TABLE gpo_refresh_token_scope (
  gpors_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpor_id INTEGER,
  gpors_scope TEXT NOT NULL,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);

-- Access token table, to store meta information on access token sent
CREATE TABLE gpo_access_token (
  gpoa_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoa_plugin_name TEXT NOT NULL,
  gpoa_authorization_type INTEGER NOT NULL,
  gpor_id INTEGER DEFAULT NULL,
  gpoa_username TEXT,
  gpoa_client_id TEXT,
  gpoa_resource TEXT,
  gpoa_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoa_issued_for TEXT, -- IP address or hostname
  gpoa_user_agent TEXT,
  gpoa_token_hash TEXT NOT NULL,
  gpoa_jti TEXT,
  gpoa_authorization_details TEXT DEFAULT NULL,
  gpoa_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);
CREATE INDEX i_gpoa_token_hash ON gpo_access_token(gpoa_token_hash);
CREATE INDEX i_gpoa_jti ON gpo_access_token(gpoa_jti);

CREATE TABLE gpo_access_token_scope (
  gpoas_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoa_id INTEGER,
  gpoas_scope TEXT NOT NULL,
  FOREIGN KEY(gpoa_id) REFERENCES gpo_access_token(gpoa_id) ON DELETE CASCADE
);

-- Id token table, to store meta information on id token sent
CREATE TABLE gpo_id_token (
  gpoi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoc_id INTEGER,
  gpor_id INTEGER,
  gpoi_plugin_name TEXT NOT NULL,
  gpoi_authorization_type INTEGER NOT NULL,
  gpoi_username TEXT,
  gpoi_client_id TEXT,
  gpoi_issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoi_issued_for TEXT, -- IP address or hostname
  gpoi_user_agent TEXT,
  gpoi_hash TEXT,
  gpoi_sid TEXT,
  gpoi_enabled INTEGER DEFAULT 1,
  FOREIGN KEY(gpoc_id) REFERENCES gpo_code(gpoc_id) ON DELETE CASCADE,
  FOREIGN KEY(gpor_id) REFERENCES gpo_refresh_token(gpor_id) ON DELETE CASCADE
);
CREATE INDEX i_gpoi_hash ON gpo_id_token(gpoi_hash);

-- subject identifier table to store subs and their relations to usernames, client_id and sector_identifier
CREATE TABLE gpo_subject_identifier (
  gposi_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gposi_plugin_name TEXT NOT NULL,
  gposi_username TEXT NOT NULL,
  gposi_client_id TEXT,
  gposi_sector_identifier_uri TEXT,
  gposi_sub TEXT NOT NULL
);
CREATE INDEX i_gposi_sub ON gpo_subject_identifier(gposi_sub);

-- store meta information on client registration
CREATE TABLE gpo_client_registration (
  gpocr_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpocr_plugin_name TEXT NOT NULL,
  gpocr_cient_id TEXT NOT NULL,
  gpocr_management_at_hash TEXT,
  gpocr_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoa_id INTEGER,
  gpocr_issued_for TEXT, -- IP address or hostname
  gpocr_user_agent TEXT,
  FOREIGN KEY(gpoa_id) REFERENCES gpo_access_token(gpoa_id) ON DELETE CASCADE
);
CREATE INDEX i_gpocr_management_at_hash ON gpo_client_registration(gpocr_management_at_hash);

-- store meta information about client request on token endpoint
CREATE TABLE gpo_client_token_request (
  gpoctr_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoctr_plugin_name TEXT NOT NULL,
  gpoctr_cient_id TEXT NOT NULL,
  gpoctr_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoctr_issued_for TEXT, -- IP address or hostname
  gpoctr_jti_hash TEXT
);

-- store device authorization requests
CREATE TABLE gpo_device_authorization (
  gpoda_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoda_plugin_name TEXT NOT NULL,
  gpoda_client_id TEXT NOT NULL,
  gpoda_resource TEXT,
  gpoda_username TEXT,
  gpoda_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoda_expires_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gpoda_issued_for TEXT, -- IP address or hostname of the device client
  gpoda_device_code_hash TEXT NOT NULL,
  gpoda_user_code_hash TEXT NOT NULL,
  gpoda_sid TEXT,
  gpoda_status INTEGER DEFAULT 0, -- 0: created, 1: user verified, 2 device completed, 3 disabled
  gpoda_authorization_details TEXT DEFAULT NULL,
  gpoda_last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpoda_device_code_hash ON gpo_device_authorization(gpoda_device_code_hash);
CREATE INDEX i_gpoda_user_code_hash ON gpo_device_authorization(gpoda_user_code_hash);

CREATE TABLE gpo_device_authorization_scope (
  gpodas_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoda_id INTEGER,
  gpodas_scope TEXT NOT NULL,
  gpodas_allowed INTEGER DEFAULT 0,
  FOREIGN KEY(gpoda_id) REFERENCES gpo_device_authorization(gpoda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_device_scheme (
  gpodh_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpoda_id INTEGER,
  gpodh_scheme_module TEXT NOT NULL,
  FOREIGN KEY(gpoda_id) REFERENCES gpo_device_authorization(gpoda_id) ON DELETE CASCADE
);

CREATE TABLE gpo_dpop (
  gpod_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpod_plugin_name TEXT NOT NULL,
  gpod_client_id TEXT NOT NULL,
  gpod_jti_hash TEXT NOT NULL,
  gpod_jkt TEXT NOT NULL,
  gpod_htm TEXT NOT NULL,
  gpod_htu TEXT NOT NULL,
  gpod_iat TIMESTAMP NOT NULL,
  gpod_last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX i_gpod_jti_hash ON gpo_dpop(gpod_jti_hash);

CREATE TABLE gpo_rar (
  gporar_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gporar_plugin_name TEXT NOT NULL,
  gporar_client_id TEXT NOT NULL,
  gporar_type TEXT NOT NULL,
  gporar_username TEXT,
  gporar_consent INTEGER DEFAULT 0,
  gporar_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gporar_client_id ON gpo_rar(gporar_client_id);
CREATE INDEX i_gporar_type ON gpo_rar(gporar_type);
CREATE INDEX i_gporar_username ON gpo_rar(gporar_username);

CREATE TABLE gpo_par (
  gpop_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpop_plugin_name TEXT NOT NULL,
  gpop_response_type TEXT NOT NULL,
  gpop_state TEXT,
  gpop_username TEXT,
  gpop_client_id TEXT NOT NULL,
  gpop_redirect_uri TEXT NOT NULL,
  gpop_request_uri_hash TEXT NOT NULL,
  gpop_nonce TEXT,
  gpop_code_challenge TEXT,
  gpop_resource TEXT,
  gpop_claims_request TEXT DEFAULT NULL,
  gpop_authorization_details TEXT DEFAULT NULL,
  gpop_additional_parameters TEXT DEFAULT NULL,
  gpop_status INTEGER DEFAULT 0, -- 0 created, 1 validated, 2 completed
  gpop_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpop_issued_for TEXT, -- IP address or hostname
  gpop_user_agent TEXT
);
CREATE INDEX i_gpop_client_id ON gpo_par(gpop_client_id);
CREATE INDEX i_gpop_request_uri_hash ON gpo_par(gpop_request_uri_hash);
CREATE INDEX i_gpop_code_challenge ON gpo_par(gpop_code_challenge);

CREATE TABLE gpo_par_scope (
  gpops_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpop_id INTEGER,
  gpops_scope TEXT NOT NULL,
  FOREIGN KEY(gpop_id) REFERENCES gpo_par(gpop_id) ON DELETE CASCADE
);

CREATE TABLE gpo_ciba (
  gpob_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpob_plugin_name TEXT NOT NULL,
  gpob_client_id TEXT NOT NULL,
  gpob_x5t_s256 TEXT,
  gpob_username TEXT NOT NULL,
  gpob_client_notification_token TEXT,
  gpob_jti_hash TEXT,
  gpob_auth_req_id TEXT,
  gpob_user_req_id TEXT,
  gpob_binding_message TEXT,
  gpob_sid TEXT,
  gpob_status INTEGER DEFAULT 0, -- 0: created, 1: accepted, 2: error, 3: closed
  gpob_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gpob_issued_for TEXT, -- IP address or hostname
  gpob_user_agent TEXT,
  gpob_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gpob_client_id ON gpo_ciba(gpob_client_id);
CREATE INDEX i_gpob_jti_hash ON gpo_ciba(gpob_jti_hash);
CREATE INDEX i_gpob_client_notification_token ON gpo_ciba(gpob_client_notification_token);
CREATE INDEX i_gpob_auth_req_id ON gpo_ciba(gpob_auth_req_id);
CREATE INDEX i_gpob_user_req_id ON gpo_ciba(gpob_user_req_id);

CREATE TABLE gpo_ciba_scope (
  gpocs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpob_id INTEGER,
  gpops_scope TEXT NOT NULL,
  gpobs_granted INTEGER DEFAULT 0,
  FOREIGN KEY(gpob_id) REFERENCES gpo_ciba(gpob_id) ON DELETE CASCADE
);

CREATE TABLE gpo_ciba_scheme (
  gpobh_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gpob_id INTEGER,
  gpobh_scheme_module TEXT NOT NULL,
  FOREIGN KEY(gpob_id) REFERENCES gpo_ciba(gpob_id) ON DELETE CASCADE
);

CREATE TABLE gs_code (
  gsc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gsc_mod_name TEXT NOT NULL,
  gsc_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsc_username TEXT NOT NULL,
  gsc_enabled INTEGER DEFAULT 1,
  gsc_code_hash TEXT,
  gsc_result INTEGER DEFAULT 0
);
CREATE INDEX i_gsc_username ON gs_code(gsc_username);

CREATE TABLE gs_webauthn_user (
  gswu_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gswu_mod_name TEXT NOT NULL,
  gswu_username TEXT NOT NULL,
  gswu_user_id TEXT NOT NULL
);
CREATE INDEX i_gswu_username ON gs_webauthn_user(gswu_username);

CREATE TABLE gs_webauthn_credential (
  gswc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gswu_id INTEGER NOT NULL,
  gswc_session_hash TEXT NOT NULL,
  gswc_name TEXT,
  gswc_challenge_hash TEXT,
  gswc_credential_id TEXT,
  gswc_certificate TEXT DEFAULT NULL,
  gswc_public_key TEXT DEFAULT NULL,
  gswc_counter INTEGER DEFAULT 0,
  gswc_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gswc_status INTEGER DEFAULT 0, -- 0 new, 1 registered, 2 error, 3 disabled, 4 removed
  FOREIGN KEY(gswu_id) REFERENCES gs_webauthn_user(gswu_id) ON DELETE CASCADE
);
CREATE INDEX i_gswc_credential_id ON gs_webauthn_credential(gswc_credential_id);
CREATE INDEX i_gswc_session_hash ON gs_webauthn_credential(gswc_session_hash);

CREATE TABLE gs_webauthn_assertion (
  gswa_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gswu_id INTEGER NOT NULL,
  gswc_id INTEGER,
  gswa_session_hash TEXT NOT NULL,
  gswa_challenge_hash TEXT,
  gswa_counter INTEGER DEFAULT 0,
  gswa_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gswa_status SMALLINT DEFAULT 0, -- 0 new, 1 verified, 2 not verified, 3 error
  gswa_mock SMALLINT DEFAULT 0,
  FOREIGN KEY(gswu_id) REFERENCES gs_webauthn_user(gswu_id) ON DELETE CASCADE,
  FOREIGN KEY(gswc_id) REFERENCES gs_webauthn_credential(gswc_id) ON DELETE CASCADE
);
CREATE INDEX i_gswa_session_hash ON gs_webauthn_assertion(gswa_session_hash);

CREATE TABLE gs_otp (
  gso_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gso_mod_name TEXT NOT NULL,
  gso_issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gso_last_used TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gso_username TEXT NOT NULL,
  gso_otp_type INTEGER DEFAULT 0, -- 0 HOTP, 1 TOTP
  gso_secret TEXT NOT NULL,
  gso_hotp_moving_factor INTEGER,
  gso_totp_time_step_size INTEGER
);
CREATE INDEX i_gsso_username ON gs_otp(gso_username);

CREATE TABLE gs_user_certificate (
  gsuc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gsuc_mod_name TEXT NOT NULL,
  gsuc_username TEXT NOT NULL,
  gsuc_enabled INTEGER DEFAULT 1,
  gsuc_x509_certificate_content TEXT DEFAULT NULL,
  gsuc_x509_certificate_id TEXT NOT NULL,
  gsuc_x509_certificate_dn TEXT NOT NULL,
  gsuc_x509_certificate_issuer_dn TEXT NOT NULL,
  gsuc_activation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsuc_expiration TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gsuc_last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  gsuc_last_user_agent TEXT DEFAULT NULL
);
CREATE INDEX i_gsuc_username ON gs_user_certificate(gsuc_username);
CREATE INDEX i_gsuc_x509_certificate_id ON gs_user_certificate(gsuc_x509_certificate_id);

CREATE TABLE gpr_session (
  gprs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gprs_plugin_name TEXT NOT NULL,
  gprs_username TEXT NOT NULL,
  gprs_name TEXT,
  gprs_email TEXT,
  gprs_code_hash TEXT,
  gprs_callback_url TEXT DEFAULT NULL,
  gprs_password_set INTEGER DEFAULT 0,
  gprs_session_hash TEXT,
  gprs_token_hash TEXT,
  gprs_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprs_issued_for TEXT, -- IP address or hostname
  gprs_user_agent TEXT,
  gprs_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gprs_session_hash ON gpr_session(gprs_session_hash);
CREATE INDEX i_gprs_gprs_token_hash ON gpr_session(gprs_token_hash);
CREATE INDEX i_gprs_gprs_gprs_code_hash ON gpr_session(gprs_code_hash);

CREATE TABLE gpr_update_email (
  gprue_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gprue_plugin_name TEXT NOT NULL,
  gprue_username TEXT NOT NULL,
  gprue_email TEXT,
  gprue_token_hash TEXT,
  gprue_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprue_issued_for TEXT, -- IP address or hostname
  gprue_user_agent TEXT,
  gprue_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gprue_token_hash ON gpr_update_email(gprue_token_hash);

CREATE TABLE gpr_reset_credentials_session (
  gprrcs_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gprrcs_plugin_name TEXT NOT NULL,
  gprrcs_username TEXT NOT NULL,
  gprrcs_session_hash TEXT,
  gprrcs_callback_url TEXT DEFAULT NULL,
  gprrcs_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprrcs_issued_for TEXT, -- IP address or hostname
  gprrcs_user_agent TEXT,
  gprrcs_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gprrcs_session_hash ON gpr_reset_credentials_session(gprrcs_session_hash);

CREATE TABLE gpr_reset_credentials_email (
  gprrct_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gprrct_plugin_name TEXT NOT NULL,
  gprrct_username TEXT NOT NULL,
  gprrct_token_hash TEXT,
  gprrct_callback_url TEXT DEFAULT NULL,
  gprrct_expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gprrct_issued_for TEXT, -- IP address or hostname
  gprrct_user_agent TEXT,
  gprrct_enabled INTEGER DEFAULT 1
);
CREATE INDEX i_gprrct_token_hash ON gpr_reset_credentials_email(gprrct_token_hash);

CREATE TABLE gs_oauth2_registration (
  gsor_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gsor_mod_name TEXT NOT NULL,
  gsor_provider TEXT NOT NULL,
  gsor_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsor_username TEXT NOT NULL,
  gsor_userinfo_sub TEXT
);
CREATE INDEX i_gsor_username ON gs_oauth2_registration(gsor_username);

CREATE TABLE gs_oauth2_session (
  gsos_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gsor_id INTEGER,
  gsos_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gsos_expires_at TIMESTAMP,
  gsos_state TEXT NOT NULL,
  gsos_session_export TEXT,
  gsos_status INTEGER DEFAULT 0, -- 0: registration, 1: authentication, 2: verified, 3: cancelled
  FOREIGN KEY(gsor_id) REFERENCES gs_oauth2_registration(gsor_id) ON DELETE CASCADE
);

INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('g_admin', 'Glewlwyd administration', 'Access to Glewlwyd''s administration API', 1, 600);
INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('g_profile', 'Glewlwyd profile', 'Access to the user''s profile API', 1, 600);
INSERT INTO g_scope (gs_name, gs_display_name, gs_description, gs_password_required, gs_password_max_age) VALUES ('openid', 'Open ID', 'Open ID Connect scope', 0, 0);
INSERT INTO g_user_module_instance (gumi_module, gumi_order, gumi_name, gumi_display_name, gumi_parameters, gumi_readonly) VALUES ('database', 0, 'database', 'Database backend', '{"use-glewlwyd-connection":true,"data-format":{"picture":{"multiple":false,"read":true,"write":true,"profile-read":true,"profile-write":true},"reset-credentials-code":{"multiple":false,"read":true,"write":true,"profile-read":false,"profile-write":false}}}', 0);
INSERT INTO g_client_module_instance (gcmi_module, gcmi_order, gcmi_name, gcmi_display_name, gcmi_parameters, gcmi_readonly) VALUES ('database', 0, 'database', 'Database backend', '{"use-glewlwyd-connection":true,"data-format":{"redirect_uri":{"multiple":true,"read":true,"write":true},"authorization_type":{"multiple":true,"read":true,"write":true},"response_mode":{"multiple":false,"read":true,"write":true},"sector_identifier_uri":{"multiple":false,"read":true,"write":true},"token_endpoint_auth_method":{"multiple":true,"read":true,"write":true},"client_secret":{"multiple":false,"read":true,"write":true},"jwks":{"convert":"jwks","multiple":false,"read":true,"write":true},"jwks_uri":{"multiple":false,"read":true,"write":true},"pubkey":{"multiple":false,"read":true,"write":true},"enc":{"multiple":false,"read":true,"write":true},"alg":{"multiple":false,"read":true,"write":true},"alg_kid":{"multiple":false,"read":true,"write":true},"encrypt_code":{"multiple":false,"read":true,"write":true},"encrypt_at":{"multiple":false,"read":true,"write":true},"encrypt_userinfo":{"multiple":false,"read":true,"write":true},"encrypt_id_token":{"multiple":false,"read":true,"write":true},"encrypt_refresh_token":{"multiple":false,"read":true,"write":true},"resource":{"multiple":true,"read":true,"write":true},"authorization_data_types":{"multiple":true,"read":true,"write":true},"tls_client_auth_san_dns":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_uri":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_ip":{"multiple":false,"read":true,"write":true},"tls_client_auth_san_email":{"multiple":false,"read":true,"write":true},"backchannel_token_delivery_mode":{"multiple":false,"read":true,"write":true},"backchannel_client_notification_endpoint":{"multiple":false,"read":true,"write":true},"backchannel_user_code_parameter":{"multiple":false,"read":true,"write":true},"request_object_signing_alg":{"multiple":false,"read":true,"write":true},"token_endpoint_signing_alg":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_signing_alg":{"multiple":false,"read":true,"write":true},"request_object_encryption_alg":{"multiple":false,"read":true,"write":true},"request_object_encryption_enc":{"multiple":false,"read":true,"write":true},"token_endpoint_encryption_alg":{"multiple":false,"read":true,"write":true},"token_endpoint_encryption_enc":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_encryption_alg":{"multiple":false,"read":true,"write":true},"backchannel_authentication_request_encryption_enc":{"multiple":false,"read":true,"write":true},"post_logout_redirect_uri":{"multiple":false,"read":true,"write":true},"frontchannel_logout_uri":{"multiple":false,"read":true,"write":true},"frontchannel_logout_session_required":{"multiple":false,"read":true,"write":true},"backchannel_logout_uri":{"multiple":false,"read":true,"write":true},"backchannel_logout_session_required":{"multiple":false,"read":true,"write":true}}}', 0);
INSERT INTO g_user (gu_username, gu_name, gu_email, gu_enabled) VALUES ('admin', 'The Administrator', '', 1);
INSERT INTO g_user_password (gu_id, guw_password) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), 'fOfvZC/wR2cUSTWbW6YZueGyyDuFqwkoFlcNlRYWJscxYTVOVFJ3VWFHdVJQT0pU');
INSERT INTO g_user_scope (gus_name) VALUES ('g_admin');
INSERT INTO g_user_scope (gus_name) VALUES ('g_profile');
INSERT INTO g_user_scope_user (gu_id, gus_id) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), (SELECT gus_id FROM g_user_scope WHERE gus_name='g_admin'));
INSERT INTO g_user_scope_user (gu_id, gus_id) VALUES ((SELECT gu_id from g_user WHERE gu_username='admin'), (SELECT gus_id FROM g_user_scope WHERE gus_name='g_profile'));
