create table workspaces
(
    name char(200),
    id   integer generated always as identity
        constraint workspaces_pk
            primary key
);

create table openings
(
    id          integer generated always as identity
        constraint openings_pk
            primary key,
    name        char(200)             not null,
    workspace   integer
        constraint openings_workspaces_fk
            references workspaces,
    description text default ''::text not null
);

create table tests
(
    id          integer generated always as identity
        constraint tests_pk
            primary key,
    name        char(200)             not null,
    description text default ''::text not null,
    opening     integer               not null
        constraint tests_openings_fk
            references openings
);

create table test_versions
(
    id       integer generated always as identity
        constraint test_versions_pk
            primary key,
    version  integer not null,
    versions integer
        constraint test_versions_tests_null_fk
            references tests
);

create table candidates
(
    id         integer generated always as identity
        constraint candidates_pk
            primary key,
    email      char(256),
    ip_address char(39),
    applied    integer default 1 not null
        constraint foreign_key_name
            references openings
);

create index candidates_sanitized_emails_idx
    on candidates (sanitize_email2(email::character varying));

create index candidates_ip_adrr_idx
    on candidates (ip_address);

create index candidates_openings_fk_ids
    on candidates (applied);

create table test_takes
(
    id           integer generated always as identity
        constraint test_takes_pk
            primary key,
    score        real,
    candidate    integer not null
        constraint test_takes_candidates_fk
            references candidates,
    test_version integer not null
        constraint test_takes_test_versions_fk
            references test_versions,
    started      timestamp,
    submitted    timestamp
);

create table question_types
(
    id   integer generated always as identity
        constraint question_types_pk
            primary key,
    name char(30) not null
);

create table questions
(
    id           integer generated always as identity
        constraint questions_pk
            primary key,
    text         text default ''::text not null,
    test_version integer               not null
        constraint questions_test_versions_fk
            references test_versions,
    type         integer
        constraint question_type_fk
            references question_types
);

create table options
(
    id          integer generated always as identity
        constraint options_pk
            primary key,
    description text default ''::text not null,
    question    integer               not null
        constraint options_questions_fk
            references questions,
    correct     boolean               not null
);

create table awnsers
(
    id        integer generated always as identity
        constraint awnsers_pk
            primary key,
    question  integer not null
        constraint awnsers_questions_fk
            references questions,
    response  jsonb,
    test_take integer not null
        constraint awnsers_test_takes_fk
            references test_takes
);

create table fraud_events
(
    event  char(50),
    data   jsonb,
    id     integer generated always as identity
        constraint fraud_events_pk
            primary key,
    awnser integer not null
        constraint fraud_events_awnsers_null_fk
            references awnsers
            on delete cascade
);

create function sanitize_email2(email character varying) returns character varying
    immutable
    language plpgsql
as
$$
    DECLARE
        tmp_array varchar[];
        position_plus int;
        sanitized_email varchar;
    BEGIN
        tmp_array =  regexp_split_to_array(email, '@');
        position_plus = position('+' in tmp_array[1]);
        IF position_plus > 0 THEN
            tmp_array[1] = overlay(tmp_array[1] placing '' from position_plus for 64);
        END IF;
        tmp_array[1] = replace(tmp_array[1], '.', '');
        sanitized_email = array_to_string(tmp_array, '@');
        return lower(sanitized_email);
    end;
$$;


