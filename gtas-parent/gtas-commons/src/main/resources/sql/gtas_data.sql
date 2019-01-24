-- ----------------------------
-- Roles
-- ----------------------------
INSERT INTO `role` VALUES ('1', 'Admin');
INSERT INTO `role` VALUES ('2', 'Manage Queries');
INSERT INTO `role` VALUES ('3', 'View Flight And Passenger');
INSERT INTO `role` VALUES ('4', 'Manage Watch List');
INSERT INTO `role` VALUES ('5', 'Manage Rules');


-- ----------------------------
-- Users
-- ----------------------------
-- password is 'password'
INSERT INTO `user` VALUES ('gtas',1, 'GTAS', 'Application User', '$2a$10$0rGc.QzA0MH7MM7OXqynJ.2Cnbdf9PiNk4ffi4ih6LSW3y21OkspG');
INSERT INTO `user` VALUES ('admin',1, 'Admin', 'Admin', '$2a$10$0rGc.QzA0MH7MM7OXqynJ.2Cnbdf9PiNk4ffi4ih6LSW3y21OkspG');

-- ----------------------------
-- Records of user_role
-- ----------------------------

INSERT INTO `user_role` (`user_id`, `role_id`) VALUES ('gtas', 1);
INSERT INTO `user_role` (`user_id`, `role_id`) VALUES ('admin', 5);

-- ----------------------------
-- Records of flight_direction
-- ----------------------------

INSERT INTO `flight_direction` VALUES (1,'I', 'Inbound');
INSERT INTO `flight_direction` VALUES (2,'O', 'Outbound');
INSERT INTO `flight_direction` VALUES (3,'C', 'Continuance');
INSERT INTO `flight_direction` VALUES (4,'A', 'Any');

-- ----------------------------
-- Records of app_configuration
-- ----------------------------
insert into app_configuration (opt, val, description) values('HOME_COUNTRY', 'USA', 'home country for the loader to determine incoming/outgoing flights');
insert into app_configuration (opt, val, description) values('ELASTIC_HOSTNAME','localhost','ElasticSearch hostname');
insert into app_configuration (opt, val, description) values('ELASTIC_PORT','9300','ElasticSearch port');
insert into app_configuration (opt, val, description) values('QUEUE_OUT', 'GTAS_Q_OUT', 'queue name for storing outgoing messages');
insert into app_configuration (opt, val, description) values('QUEUE_IN', 'GTAS_Q_IN', 'queue name for storing incoming messages');
insert into app_configuration (opt, val, description) values('UPLOAD_DIR', 'C:\\MESSAGE', 'directory for uploading files from UI');
insert into app_configuration (opt, val, description) values('HOURLY_ADJ','-5','Dashboard Time Adjustment');
insert into app_configuration (opt, val, description) values('DASHBOARD_AIRPORT','IAD','Dashboard Airport');
insert into app_configuration (opt, val, description) values('SMS_TOPIC_ARN','','The ARN of the topic used by SmsService');
insert into app_configuration (opt, val, description) values('MATCHING_THRESHOLD','.85','Threshold which to determine name match');
insert into app_configuration (opt, val, description) values('MAX_PASSENGER_QUERY_RESULT','1000','Maximum amount of passenger results from query allowed');
insert into app_configuration (opt, val, description) values('MAX_FLIGHT_QUERY_RESULT','1000','Maximum amount of flight results from query allowed');
insert into app_configuration (opt, val, description) values('FLIGHT_RANGE','3','Time range for adding flights to name matching queue');
insert into app_configuration (opt, val, description) values('REDIS_KEYS_TTL','5','Number of days indexed REDIS Keys to expire in');
insert into app_configuration (opt, val, description) values('REDIS_KEYS_TTL_TIME_UNIT','DAYS','REDIS keys expiration time units - DAYS or MINUTES ');
insert into app_configuration (opt, val, description) values('APIS_ONLY_FLAG','FALSE','Is APIS the only message source in use.');
insert into app_configuration (opt, val, description) values('APIS_VERSION','16B','Latest APIS version being used.');

-- ----------------------------
-- Records of dashboard_message_stats
-- ----------------------------

INSERT INTO `dashboard_message_stats` (`id`, `dt_modified`,`message_type`, `hour_1`, `hour_2`, `hour_3`, `hour_4`, `hour_5`, `hour_6`, `hour_7`, `hour_8`, `hour_9`, `hour_10`, `hour_11`, `hour_12`, `hour_13`, `hour_14`, `hour_15`, `hour_16`, `hour_17`, `hour_18`, `hour_19`, `hour_20`, `hour_21`, `hour_22`, `hour_23`, `hour_24`) VALUES (1, CURRENT_TIMESTAMP, 'API', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO `dashboard_message_stats` (`id`, `dt_modified`,`message_type`, `hour_1`, `hour_2`, `hour_3`, `hour_4`, `hour_5`, `hour_6`, `hour_7`, `hour_8`, `hour_9`, `hour_10`, `hour_11`, `hour_12`, `hour_13`, `hour_14`, `hour_15`, `hour_16`, `hour_17`, `hour_18`, `hour_19`, `hour_20`, `hour_21`, `hour_22`, `hour_23`, `hour_24`) VALUES (2, CURRENT_TIMESTAMP, 'PNR', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

/*These 4 statuses are irremovable (though mutable) and must exist in some form in order to preserve the case management flow, with this order for ID purposes. */
insert into disposition_status(id, name, description) values(1, 'NEW', 'New Case');
insert into disposition_status(id, name, description) values(2, 'OPEN', 'Case is open');
insert into disposition_status(id, name, description) values(3, 'CLOSED', 'No action required');
insert into disposition_status(id, name, description) values(4, 'RE-OPEN', 'Re-opened case');
insert into disposition_status(id, name, description) values(5, 'PENDING CLOSURE','Case is pending closure');

insert into hit_disposition_status(id, name, description) values(1, 'NEW', 'New Case');
insert into hit_disposition_status(id, name, description) values(2, 'OPEN', 'Case is open');
insert into hit_disposition_status(id, name, description) values(3, 'CLOSED', 'No action required');
insert into hit_disposition_status(id, name, description) values(4, 'RE-OPEN', 'Re-opened case');
insert into hit_disposition_status(id, name, description) values(5, 'PENDING CLOSURE','Case is pending closure');

insert into case_disposition_status(id, name, description) values(1, 'Admit', 'Admit');
insert into case_disposition_status(id, name, description) values(2, 'Deny Boarding', 'Deny Boarding');
insert into case_disposition_status(id, name, description) values(3, 'No Show', 'No Show');
insert into case_disposition_status(id, name, description) values(4, 'Cancelled', 'Cancelled');
insert into case_disposition_status(id, name, description) values(5, 'Duplicate','Duplicate');
insert into case_disposition_status(id, name, description) values(6, 'Refuse Entry', 'Refuse Entry');
insert into case_disposition_status(id, name, description) values(7, 'Secondary Referral', 'Secondary Referral');
insert into case_disposition_status(id, name, description) values(8, 'False Match', 'False Match');


insert into rule_category(catId, category, description, priority) values(1, 'General', 'General category', 5);
insert into rule_category(catId, category, description, priority) values(2, 'Terrorism', 'Terrorism related entities', 1);
insert into rule_category(catId, category, description, priority) values(3, 'World Health', 'Health Alert related', 2);
insert into rule_category(catId, category, description, priority) values(4, 'Federal Law Enforcement', 'Federal watch category', 3);
insert into rule_category(catId, category, description, priority) values(5, 'Local Law Enforcement', 'Local watch category', 4);

