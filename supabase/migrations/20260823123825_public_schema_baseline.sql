set local check_function_bodies = off;

-- Prerequisite: apply PastPapers.ContentApi EF Core migrations before
-- applying this public-schema baseline.

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "anon";

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "authenticated";

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "service_role";

alter default privileges for role "postgres" in schema "public" revoke all on tables from "anon";

alter default privileges for role "postgres" in schema "public" revoke all on tables from "authenticated";

alter default privileges for role "postgres" in schema "public" revoke all on tables from "service_role";

create table "public"."comment_reports" (
  "id"               uuid                     not null default gen_random_uuid(),
  "comment_id"       uuid                     not null,
  "reporter_user_id" uuid                     not null,
  "reported_user_id" uuid,
  "reason"           character varying(30)    not null,
  "details"          text,
  "status"           character varying(20)    not null default 'Pending'::character varying,
  "created_at"       timestamp with time zone not null default now(),
  "updated_at"       timestamp with time zone not null default now(),
  "reviewed_at"      timestamp with time zone,
  "reviewer_notes"   text,
  constraint "ck_comment_reports_reviewer_notes_length" check (((reviewer_notes IS NULL) OR (char_length(reviewer_notes) <= 1000))),
  constraint "comment_reports_details_check" check (((details IS NULL) OR (char_length(details) <= 500))),
  constraint "comment_reports_pkey" primary key (id),
  constraint "comment_reports_reason_check"
    check
    (((reason)::text = ANY ((ARRAY['spam'::character varying, 'harassment'::character varying, 'inappropriate'::character varying, 'misleading'::character varying,
    'other'::character varying])::text[]))),
  constraint "comment_reports_reporter_user_id_comment_id_key" unique (reporter_user_id, comment_id),
  constraint "comment_reports_status_check"
    check (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Reviewed'::character varying, 'Dismissed'::character varying])::text[])))
);

alter table "public"."comment_reports"
  enable row level security;

create table "public"."community_guidelines_acceptances" (
  "user_id"            uuid                     not null,
  "guidelines_version" character varying(30)    not null,
  "accepted_at"        timestamp with time zone not null default now(),
  constraint "community_guidelines_acceptances_guidelines_version_check" check ((char_length(TRIM(BOTH FROM guidelines_version)) > 0)),
  constraint "community_guidelines_acceptances_pkey" primary key (user_id, guidelines_version)
);

alter table "public"."community_guidelines_acceptances"
  enable row level security;

create table "public"."profiles" (
  "user_id"      uuid                     not null,
  "display_name" character varying(40),
  "grade"        smallint,
  "created_at"   timestamp with time zone not null default now(),
  "updated_at"   timestamp with time zone not null default now(),
  constraint "ck_profiles_display_name" check (((display_name IS NULL) OR ((char_length(btrim((display_name)::text)) >= 2) AND (char_length(btrim((display_name)::text)) <= 40)))),
  constraint "ck_profiles_grade" check (((grade IS NULL) OR ((grade >= 10) AND (grade <= 12)))),
  constraint "profiles_pkey" primary key (user_id)
);

alter table "public"."profiles"
  enable row level security;

create table "public"."question_bookmarks" (
  "user_id"     uuid                     not null,
  "question_id" uuid                     not null,
  "created_at"  timestamp with time zone not null default now(),
  constraint "pk_question_bookmarks" primary key (user_id, question_id)
);

alter table "public"."question_bookmarks"
  enable row level security;

create table "public"."question_comments" (
  "id"                uuid                     not null default gen_random_uuid(),
  "question_id"       uuid                     not null,
  "user_id"           uuid                     not null,
  "body"              text                     not null,
  "external_url"      text,
  "link_provider"     character varying(20),
  "moderation_status" character varying(20)    not null default 'Visible'::character varying,
  "created_at"        timestamp with time zone not null default now(),
  "updated_at"        timestamp with time zone not null default now(),
  "deleted_at"        timestamp with time zone,
  constraint "ck_question_comments_body" check (((char_length(btrim(body)) >= 2) AND (char_length(btrim(body)) <= 1000))),
  constraint "ck_question_comments_external_url" check (((external_url IS NULL) OR (char_length(external_url) <= 500))),
  constraint "ck_question_comments_link" check ((((external_url IS NULL) AND (link_provider IS NULL)) OR ((external_url IS
    NOT NULL) AND ((link_provider)::text = ANY ((ARRAY['youtube'::character varying, 'tiktok'::character varying])::text[]))))),
  constraint "ck_question_comments_moderation" check (((moderation_status)::text = ANY ((ARRAY['Visible'::character varying, 'Hidden'::character varying])::text[]))),
  constraint "question_comments_pkey" primary key (id)
);

alter table "public"."question_comments"
  enable row level security;

create table "public"."question_items" (
  "id"               uuid                     not null default gen_random_uuid(),
  "subject_id"       character varying(50)    not null,
  "grade"            integer                  not null,
  "primary_topic_id" character varying(50)    not null,
  "exam_year"        integer                  not null,
  "exam_season"      character varying(50)    not null,
  "paper"            character varying(20)    not null,
  "question_number"  character varying(10),
  "image_url"        text                     not null,
  "answer_image_url" text                     not null,
  "created_at"       timestamp with time zone default now(),
  constraint "question_items_pkey" primary key (id)
);

alter table "public"."question_items"
  enable row level security;

create table "public"."question_progress" (
  "user_id"           uuid                     not null,
  "question_id"       uuid                     not null,
  "topic_id"          uuid                     not null,
  "status"            text                     not null,
  "review_count"      integer                  not null default 1,
  "first_reviewed_at" timestamp with time zone not null default now(),
  "last_reviewed_at"  timestamp with time zone not null default now(),
  constraint "ck_question_progress_review_count" check ((review_count >= 1)),
  constraint "ck_question_progress_status" check ((status = ANY (ARRAY['understood'::text, 'needs_review'::text]))),
  constraint "pk_question_progress" primary key (user_id, question_id)
);

alter table "public"."question_progress"
  enable row level security;

create table "public"."user_blocks" (
  "blocker_user_id" uuid                     not null,
  "blocked_user_id" uuid                     not null,
  "created_at"      timestamp with time zone not null default now(),
  constraint "user_blocks_check" check ((blocker_user_id <> blocked_user_id)),
  constraint "user_blocks_pkey" primary key (blocker_user_id, blocked_user_id)
);

alter table "public"."user_blocks"
  enable row level security;

create or replace function public.accept_community_guidelines()
  returns timestamp with time zone
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_user_id uuid := auth.uid();
    v_version constant text := 'v1';
    v_accepted_at timestamptz;
begin
    if v_user_id is null then
        raise exception 'Authentication is required.';
    end if;

    insert into public.community_guidelines_acceptances
    (
        user_id,
        guidelines_version
    )
    values
    (
        v_user_id,
        v_version
    )
    on conflict (user_id, guidelines_version)
    do nothing;

    select acceptance.accepted_at
    into v_accepted_at
    from public.community_guidelines_acceptances
        as acceptance
    where acceptance.user_id = v_user_id
      and acceptance.guidelines_version = v_version;

    return v_accepted_at;
end;
$function$;

create or replace function public.block_comment_author (
  p_comment_id uuid
)
  returns uuid
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_blocker_user_id uuid := auth.uid();
    v_blocked_user_id uuid;
begin
    if v_blocker_user_id is null then
        raise exception 'Authentication is required.';
    end if;

    select comment.user_id
    into v_blocked_user_id
    from public.question_comments as comment
    where comment.id = p_comment_id
      and comment.deleted_at is null
      and comment.moderation_status = 'Visible';

    if v_blocked_user_id is null then
        raise exception 'Comment does not exist or is unavailable.';
    end if;

    if v_blocked_user_id = v_blocker_user_id then
        raise exception 'You cannot block yourself.';
    end if;

    insert into public.user_blocks
    (
        blocker_user_id,
        blocked_user_id
    )
    values
    (
        v_blocker_user_id,
        v_blocked_user_id
    )
    on conflict (blocker_user_id, blocked_user_id)
    do nothing;

    return v_blocked_user_id;
end;
$function$;

create or replace function public.create_question_comment (
  p_question_id  uuid,
  p_body         text,
  p_external_url text default null::text
)
  returns table (
    comment_id          uuid,
    question_id         uuid,
    author_user_id      uuid,
    author_display_name text,
    body                text,
    external_url        text,
    link_provider       text,
    is_own_comment      boolean,
    created_at          timestamp with time zone,
    updated_at          timestamp with time zone
  )
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
#variable_conflict use_column
declare
    v_user_id uuid;
    v_body text;
    v_url text;
    v_provider text;
    v_display_name text;
    v_comment_id uuid;
    v_guidelines_version constant text := 'v1';
begin
    v_user_id := auth.uid();
    v_body := btrim(p_body);
    v_url := nullif(btrim(p_external_url), '');

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    if not exists
    (
        select 1
        from public.community_guidelines_acceptances
            as acceptance
        where acceptance.user_id = v_user_id
          and acceptance.guidelines_version =
              v_guidelines_version
    ) then
        raise exception
            'Accept the Community Guidelines before commenting'
            using errcode = '42501';
    end if;

    if char_length(v_body) not between 2 and 1000 then
        raise exception
            'Comment must be between 2 and 1000 characters'
            using errcode = '22023';
    end if;

    if v_url is not null then
        if char_length(v_url) > 500 then
            raise exception 'External link is too long'
                using errcode = '22023';
        end if;

        if v_url ~*
            '^https://([a-z0-9-]+\.)*youtube\.com/'
            or v_url ~* '^https://youtu\.be/' then
            v_provider := 'youtube';

        elsif v_url ~*
            '^https://([a-z0-9-]+\.)*tiktok\.com/' then
            v_provider := 'tiktok';

        else
            raise exception
                'Only HTTPS YouTube and TikTok links are supported'
                using errcode = '22023';
        end if;
    end if;

    if not exists
    (
        select 1
        from content.questions as question
        where question.id = p_question_id
          and question.status = 'Published'
    ) then
        raise exception 'Published question not found'
            using errcode = 'P0002';
    end if;

    select profile.display_name
    into v_display_name
    from public.profiles as profile
    where profile.user_id = v_user_id;

    if v_display_name is null then
        raise exception
            'Complete your learner profile before commenting'
            using errcode = '22023';
    end if;

    insert into public.question_comments
    (
        question_id,
        user_id,
        body,
        external_url,
        link_provider
    )
    values
    (
        p_question_id,
        v_user_id,
        v_body,
        v_url,
        v_provider
    )
    returning id into v_comment_id;

    return query
    select
        comment.id,
        comment.question_id,
        comment.user_id,
        v_display_name,
        comment.body,
        comment.external_url,
        comment.link_provider::text,
        true,
        comment.created_at,
        comment.updated_at
    from public.question_comments as comment
    where comment.id = v_comment_id;
end;
$function$;

create or replace function public.delete_my_question_comment (
  p_comment_id uuid
)
  returns boolean
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_user_id uuid;
    v_affected integer;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    update public.question_comments as comment
    set
        deleted_at = now(),
        updated_at = now()
    where comment.id = p_comment_id
      and comment.user_id = v_user_id
      and comment.deleted_at is null;

    get diagnostics v_affected = row_count;

    return v_affected = 1;
end;
$function$;

create or replace function public.get_my_blocked_users()
  returns table (
    blocked_user_id uuid,
    display_name    text,
    blocked_at      timestamp with time zone
  )
  language sql
  stable
  security definer
  set search_path to ''
  AS $function$
    select
        user_block.blocked_user_id,
        coalesce(
            profile.display_name::text,
            'Learner'
        ),
        user_block.created_at
    from public.user_blocks as user_block
    left join public.profiles as profile
        on profile.user_id = user_block.blocked_user_id
    where user_block.blocker_user_id = auth.uid()
      and auth.uid() is not null
    order by user_block.created_at desc;
$function$;

create or replace function public.get_my_community_guidelines_status()
  returns table (
    guidelines_version text,
    is_accepted        boolean,
    accepted_at        timestamp with time zone
  )
  language plpgsql
  stable
  security definer
  set search_path to ''
  AS $function$
declare
    v_user_id uuid := auth.uid();
    v_version constant text := 'v1';
begin
    if v_user_id is null then
        raise exception 'Authentication is required.';
    end if;

    return query
    select
        v_version,
        acceptance.accepted_at is not null,
        acceptance.accepted_at
    from (select 1) as placeholder
    left join public.community_guidelines_acceptances
        as acceptance
        on acceptance.user_id = v_user_id
       and acceptance.guidelines_version = v_version;
end;
$function$;

create or replace function public.get_question_comments (
  p_question_id uuid,
  p_limit       integer default 50
)
  returns table (
    comment_id          uuid,
    question_id         uuid,
    author_user_id      uuid,
    author_display_name text,
    body                text,
    external_url        text,
    link_provider       text,
    is_own_comment      boolean,
    created_at          timestamp with time zone,
    updated_at          timestamp with time zone
  )
  language sql
  stable
  security definer
  set search_path to ''
  AS $function$
    select
        comment.id,
        comment.question_id,
        comment.user_id,
        coalesce(
            profile.display_name::text,
            'Learner'
        ),
        comment.body,
        comment.external_url,
        comment.link_provider::text,
        (
            auth.uid() is not null
            and auth.uid() = comment.user_id
        ),
        comment.created_at,
        comment.updated_at
    from public.question_comments as comment
    join public.profiles as profile
        on profile.user_id = comment.user_id
    where comment.question_id = p_question_id
      and comment.deleted_at is null
      and comment.moderation_status = 'Visible'
      and exists
      (
          select 1
          from content.questions as question
          where question.id = p_question_id
            and question.status = 'Published'
      )
      and
      (
          auth.uid() is null
          or not exists
          (
              select 1
              from public.user_blocks as user_block
              where user_block.blocker_user_id = auth.uid()
                and user_block.blocked_user_id = comment.user_id
          )
      )
    order by comment.created_at desc
    limit least(
        greatest(coalesce(p_limit, 50), 1),
        50
    );
$function$;

create or replace function public.get_topic_progress_summary()
  returns table (
    topic_id             uuid,
    reviewed_count       integer,
    understood_count     integer,
    needs_review_count   integer,
    review_attempt_count integer,
    last_reviewed_at     timestamp with time zone
  )
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
#variable_conflict use_column
declare
    v_user_id uuid;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    return query
    select
        progress.topic_id,
        count(*)::integer as reviewed_count,
        count(*) filter (
            where progress.status = 'understood'
        )::integer as understood_count,
        count(*) filter (
            where progress.status = 'needs_review'
        )::integer as needs_review_count,
        coalesce(
            sum(progress.review_count),
            0
        )::integer as review_attempt_count,
        max(progress.last_reviewed_at) as last_reviewed_at
    from public.question_progress as progress
    where progress.user_id = v_user_id
    group by progress.topic_id
    order by max(progress.last_reviewed_at) desc;
end;
$function$;

create or replace function public.handle_new_user()
  returns trigger
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_metadata_name text;
begin
    v_metadata_name := btrim(
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            new.raw_user_meta_data ->> 'full_name',
            ''
        )
    );

    insert into public.profiles
    (
        user_id,
        display_name
    )
    values
    (
        new.id,
        case
            when char_length(v_metadata_name)
                between 2 and 40
            then v_metadata_name
            else null
        end
    );

    return new;
end;
$function$;

create or replace function public.report_question_comment (
  p_comment_id uuid,
  p_reason     text,
  p_details    text default null::text
)
  returns uuid
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_reporter_user_id uuid := auth.uid();
    v_reported_user_id uuid;
    v_report_id uuid;
    v_reason text := lower(trim(p_reason));
    v_details text := nullif(trim(p_details), '');
begin
    if v_reporter_user_id is null then
        raise exception 'Authentication is required.';
    end if;

    if v_reason not in (
        'spam',
        'harassment',
        'inappropriate',
        'misleading',
        'other'
    ) then
        raise exception 'Invalid report reason.';
    end if;

    if v_details is not null and char_length(v_details) > 500 then
        raise exception 'Report details cannot exceed 500 characters.';
    end if;

    select comment.user_id
    into v_reported_user_id
    from public.question_comments as comment
    where comment.id = p_comment_id
      and comment.deleted_at is null
      and comment.moderation_status = 'Visible';

    if v_reported_user_id is null then
        raise exception 'Comment does not exist or is unavailable.';
    end if;

    if v_reported_user_id = v_reporter_user_id then
        raise exception 'You cannot report your own comment.';
    end if;

    insert into public.comment_reports
    (
        comment_id,
        reporter_user_id,
        reported_user_id,
        reason,
        details
    )
    values
    (
        p_comment_id,
        v_reporter_user_id,
        v_reported_user_id,
        v_reason,
        v_details
    )
    on conflict (reporter_user_id, comment_id)
    do update
    set reason = excluded.reason,
        details = excluded.details,
        reported_user_id = excluded.reported_user_id,
        status = 'Pending',
        updated_at = now()
    returning id into v_report_id;

    return v_report_id;
end;
$function$;

create or replace function public.set_profile_updated_at()
  returns trigger
  language plpgsql
  set search_path to ''
  AS $function$
begin
    new.updated_at := now();
    return new;
end;
$function$;

create or replace function public.set_question_progress (
  p_question_id uuid,
  p_status      text
)
  returns table (
    question_id       uuid,
    topic_id          uuid,
    status            text,
    review_count      integer,
    first_reviewed_at timestamp with time zone,
    last_reviewed_at  timestamp with time zone
  )
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
#variable_conflict use_column
declare
    v_user_id uuid;
    v_topic_id uuid;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    if p_status not in ('understood', 'needs_review') then
        raise exception 'Invalid progress status'
            using errcode = '22023';
    end if;

    select q.topic_id
    into v_topic_id
    from content.questions as q
    where q.id = p_question_id
      and q.status = 'Published';

    if v_topic_id is null then
        raise exception 'Published question not found'
            using errcode = 'P0002';
    end if;

    insert into public.question_progress as progress
    (
        user_id,
        question_id,
        topic_id,
        status,
        review_count,
        first_reviewed_at,
        last_reviewed_at
    )
    values
    (
        v_user_id,
        p_question_id,
        v_topic_id,
        p_status,
        1,
        now(),
        now()
    )
    on conflict on constraint pk_question_progress
    do update set
        topic_id = excluded.topic_id,
        status = excluded.status,
        review_count = progress.review_count + 1,
        last_reviewed_at = now();

    return query
    select
        progress.question_id,
        progress.topic_id,
        progress.status,
        progress.review_count,
        progress.first_reviewed_at,
        progress.last_reviewed_at
    from public.question_progress as progress
    where progress.user_id = v_user_id
      and progress.question_id = p_question_id;
end;
$function$;

create or replace function public.unblock_user (
  p_blocked_user_id uuid
)
  returns boolean
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
declare
    v_blocker_user_id uuid := auth.uid();
    v_deleted_count integer;
begin
    if v_blocker_user_id is null then
        raise exception 'Authentication is required.';
    end if;

    if p_blocked_user_id is null then
        raise exception 'Blocked user ID is required.';
    end if;

    delete from public.user_blocks
    where blocker_user_id = v_blocker_user_id
      and blocked_user_id = p_blocked_user_id;

    get diagnostics v_deleted_count = row_count;

    return v_deleted_count > 0;
end;
$function$;

create or replace function public.update_my_profile (
  p_display_name text,
  p_grade        smallint
)
  returns table (
    user_id      uuid,
    display_name text,
    grade        smallint,
    created_at   timestamp with time zone,
    updated_at   timestamp with time zone
  )
  language plpgsql
  security definer
  set search_path to ''
  AS $function$
#variable_conflict use_column
declare
    v_user_id uuid;
    v_display_name text;
begin
    v_user_id := auth.uid();
    v_display_name := btrim(p_display_name);

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    if char_length(v_display_name) not between 2 and 40 then
        raise exception
            'Display name must be between 2 and 40 characters'
            using errcode = '22023';
    end if;

    if p_grade not between 10 and 12 then
        raise exception 'Grade must be between 10 and 12'
            using errcode = '22023';
    end if;

    insert into public.profiles as profile
    (
        user_id,
        display_name,
        grade
    )
    values
    (
        v_user_id,
        v_display_name,
        p_grade
    )
    on conflict on constraint profiles_pkey
    do update set
        display_name = excluded.display_name,
        grade = excluded.grade;

    return query
    select
        profile.user_id,
        profile.display_name::text,
        profile.grade,
        profile.created_at,
        profile.updated_at
    from public.profiles as profile
    where profile.user_id = v_user_id;
end;
$function$;

alter table "public"."comment_reports"
  add constraint "comment_reports_reported_user_id_fkey" foreign key (reported_user_id) references auth.users(id) on delete set null;

alter table "public"."comment_reports"
  add constraint "comment_reports_reporter_user_id_fkey" foreign key (reporter_user_id) references auth.users(id) on delete cascade;

alter table "public"."community_guidelines_acceptances"
  add constraint "community_guidelines_acceptances_user_id_fkey" foreign key (user_id) references auth.users(id) on delete cascade;

alter table "public"."profiles"
  add constraint "profiles_user_id_fkey" foreign key (user_id) references auth.users(id) on delete cascade;

alter table "public"."question_bookmarks"
  add constraint "question_bookmarks_question_id_fkey" foreign key (question_id) references content.questions(id) on delete cascade;

alter table "public"."question_bookmarks"
  add constraint "question_bookmarks_user_id_fkey" foreign key (user_id) references auth.users(id) on delete cascade;

alter table "public"."comment_reports"
  add constraint "comment_reports_comment_id_fkey" foreign key (comment_id) references public.question_comments(id) on delete cascade;

alter table "public"."question_comments"
  add constraint "question_comments_question_id_fkey" foreign key (question_id) references content.questions(id) on delete cascade;

alter table "public"."question_comments"
  add constraint "question_comments_user_id_fkey" foreign key (user_id) references auth.users(id) on delete cascade;

alter table "public"."question_progress"
  add constraint "question_progress_question_id_fkey" foreign key (question_id) references content.questions(id) on delete cascade;

alter table "public"."question_progress"
  add constraint "question_progress_topic_id_fkey" foreign key (topic_id) references content.topics(id) on delete cascade;

alter table "public"."question_progress"
  add constraint "question_progress_user_id_fkey" foreign key (user_id) references auth.users(id) on delete cascade;

alter table "public"."user_blocks"
  add constraint "user_blocks_blocked_user_id_fkey" foreign key (blocked_user_id) references auth.users(id) on delete cascade;

alter table "public"."user_blocks"
  add constraint "user_blocks_blocker_user_id_fkey" foreign key (blocker_user_id) references auth.users(id) on delete cascade;

create index idx_topic_search on public.question_items using btree (subject_id, grade, primary_topic_id);

create index ix_comment_reports_reported_user_id on public.comment_reports using btree (reported_user_id);

create index ix_comment_reports_status_created_at on public.comment_reports using btree (status, created_at);

create index ix_community_guidelines_acceptances_version on public.community_guidelines_acceptances using btree (guidelines_version);

create index ix_profiles_grade on public.profiles using btree (grade)
  where (grade is not null);

create index ix_question_bookmarks_user_created_at on public.question_bookmarks using btree (user_id, created_at desc);

create index ix_question_comments_question_created on public.question_comments using btree (question_id, created_at desc)
  where ((deleted_at is null) AND ((moderation_status)::text = 'Visible'::text));

create index ix_question_comments_user on public.question_comments using btree (user_id);

create index ix_question_progress_user_last_reviewed on public.question_progress using btree (user_id, last_reviewed_at desc);

create index ix_question_progress_user_status on public.question_progress using btree (user_id, status);

create index ix_question_progress_user_topic on public.question_progress using btree (user_id, topic_id);

create index ix_user_blocks_blocked_user_id on public.user_blocks using btree (blocked_user_id);

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

create trigger set_profile_updated_at
  before update on public.profiles
  for each row
  execute function public.set_profile_updated_at();

create policy "Users can read their own profile" on "public"."profiles"
  for select
  to "authenticated"
  using ((( select auth.uid() as uid) = user_id));

create policy "Users can create their bookmarks" on "public"."question_bookmarks"
  for insert
  to "authenticated"
  with check ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can delete their bookmarks" on "public"."question_bookmarks"
  for delete
  to "authenticated"
  using ((( select auth.uid() as uid) = user_id));

create policy "Users can read their bookmarks" on "public"."question_bookmarks"
  for select
  to "authenticated"
  using ((( select auth.uid() as uid) = user_id));

create policy "Allow public read access" on "public"."question_items"
  for select
  to PUBLIC
  using (true);

create policy "Users can read their own question progress" on "public"."question_progress"
  for select
  to "authenticated"
  using ((( select auth.uid() as uid) = user_id));

revoke all on function "public"."accept_community_guidelines"() from public;

grant execute on function "public"."accept_community_guidelines"() to "authenticated", "postgres", "service_role";

revoke all on function "public"."block_comment_author"(uuid) from public;

grant execute on function "public"."block_comment_author"(uuid) to "authenticated", "postgres", "service_role";

revoke all on function "public"."create_question_comment"(uuid, text, text) from public;

grant execute on function "public"."create_question_comment"(uuid, text, text) to "authenticated", "postgres", "service_role";

revoke all on function "public"."delete_my_question_comment"(uuid) from public;

grant execute on function "public"."delete_my_question_comment"(uuid) to "authenticated", "postgres", "service_role";

revoke all on function "public"."get_my_blocked_users"() from public;

grant execute on function "public"."get_my_blocked_users"() to "authenticated", "postgres", "service_role";

revoke all on function "public"."get_my_community_guidelines_status"() from public;

grant execute on function "public"."get_my_community_guidelines_status"() to "authenticated", "postgres", "service_role";

revoke all on function "public"."get_question_comments"(uuid, integer) from public;

grant execute on function "public"."get_question_comments"(uuid, integer) to "anon", "authenticated", "postgres", "service_role";

revoke all on function "public"."get_topic_progress_summary"() from public;

grant execute on function "public"."get_topic_progress_summary"() to "authenticated", "postgres", "service_role";

grant execute on function "public"."handle_new_user"() to public, "anon", "authenticated", "postgres", "service_role";

revoke all on function "public"."report_question_comment"(uuid, text, text) from public;

grant execute on function "public"."report_question_comment"(uuid, text, text) to "authenticated", "postgres", "service_role";

grant execute on function "public"."set_profile_updated_at"() to public, "anon", "authenticated", "postgres", "service_role";

revoke all on function "public"."set_question_progress"(uuid, text) from public;

grant execute on function "public"."set_question_progress"(uuid, text) to "authenticated", "postgres", "service_role";

revoke all on function "public"."unblock_user"(uuid) from public;

grant execute on function "public"."unblock_user"(uuid) to "authenticated", "postgres", "service_role";

revoke all on function "public"."update_my_profile"(text, smallint) from public;

grant execute on function "public"."update_my_profile"(text, smallint) to "authenticated", "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."comment_reports" to "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."community_guidelines_acceptances" to "postgres", "service_role";

revoke all on table "public"."profiles" from "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."profiles" to "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."question_bookmarks" to "authenticated", "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."question_comments" to "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."question_items" to "anon", "authenticated", "postgres", "service_role";

revoke all on table "public"."question_progress" from "authenticated";

grant maintain, references, select, trigger, truncate on table "public"."question_progress" to "authenticated";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."question_progress" to "postgres", "service_role";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."user_blocks" to "postgres", "service_role";

alter default privileges for role "postgres" in schema "public" grant select, update, usage on sequences to "anon";

alter default privileges for role "postgres" in schema "public" grant select, update, usage on sequences to "authenticated";

alter default privileges for role "postgres" in schema "public" grant select, update, usage on sequences to "service_role";

alter default privileges for role "postgres" in schema "public" grant execute on FUNCTIONS to "anon";

alter default privileges for role "postgres" in schema "public" grant execute on FUNCTIONS to "authenticated";

alter default privileges for role "postgres" in schema "public" grant execute on FUNCTIONS to "service_role";

alter default privileges for role "postgres" in schema "public" grant delete, insert, maintain, references, select, trigger, truncate, update on tables to "anon";

alter default privileges for role "postgres" in schema "public" grant delete, insert, maintain, references, select, trigger, truncate, update on tables to "authenticated";

alter default privileges for role "postgres" in schema "public" grant delete, insert, maintain, references, select, trigger, truncate, update on tables to "service_role";
