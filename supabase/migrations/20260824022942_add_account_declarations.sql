create table public.account_declarations
(
    user_id uuid primary key
        references auth.users(id)
        on delete cascade,

    account_type character varying(40) not null,

    declaration_version character varying(40) not null,

    accepted_at timestamp with time zone not null default now(),

    constraint ck_account_declarations_account_type
        check
        (
            account_type in
            (
                'adult_learner',
                'guardian_managed_learner'
            )
        ),

    constraint ck_account_declarations_version
        check
        (
            char_length(btrim(declaration_version)) between 2 and 40
        )
);

alter table public.account_declarations
    enable row level security;

comment on table public.account_declarations is
    'Records whether an account is owned by an adult learner or managed by a parent or guardian.';

revoke all
on table public.account_declarations
from anon, authenticated;


create or replace function public.get_my_account_declaration()
returns jsonb
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
    v_user_id uuid;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    return
    (
        select jsonb_build_object(
            'account_type',
            declaration.account_type,
            'declaration_version',
            declaration.declaration_version,
            'accepted_at',
            declaration.accepted_at
        )
        from public.account_declarations as declaration
        where declaration.user_id = v_user_id
    );
end;
$function$;


create or replace function public.record_account_declaration(
    p_account_type text,
    p_declaration_accepted boolean
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
    v_user_id uuid;
    v_account_type text;
    v_declaration_version constant text :=
        'account-eligibility-v1';
begin
    v_user_id := auth.uid();
    v_account_type := btrim(coalesce(p_account_type, ''));

    if v_user_id is null then
        raise exception 'Authentication is required'
            using errcode = '42501';
    end if;

    if v_account_type not in
    (
        'adult_learner',
        'guardian_managed_learner'
    ) then
        raise exception 'Invalid account type'
            using errcode = '22023';
    end if;

    if p_declaration_accepted is distinct from true then
        raise exception 'Account declaration must be accepted'
            using errcode = '22023';
    end if;

    insert into public.account_declarations
    (
        user_id,
        account_type,
        declaration_version,
        accepted_at
    )
    values
    (
        v_user_id,
        v_account_type,
        v_declaration_version,
        now()
    )
    on conflict (user_id)
    do update
    set
        account_type = excluded.account_type,
        declaration_version = excluded.declaration_version,
        accepted_at = excluded.accepted_at;

    return
    (
        select jsonb_build_object(
            'account_type',
            declaration.account_type,
            'declaration_version',
            declaration.declaration_version,
            'accepted_at',
            declaration.accepted_at
        )
        from public.account_declarations as declaration
        where declaration.user_id = v_user_id
    );
end;
$function$;


revoke all
on function public.get_my_account_declaration()
from public, anon;

revoke all
on function public.record_account_declaration(text, boolean)
from public, anon;

grant execute
on function public.get_my_account_declaration()
to authenticated;

grant execute
on function public.record_account_declaration(text, boolean)
to authenticated;


create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
    v_metadata_name text;
    v_account_type text;
    v_declaration_accepted boolean;
    v_declaration_version constant text :=
        'account-eligibility-v1';
begin
    v_metadata_name := btrim(
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            new.raw_user_meta_data ->> 'full_name',
            ''
        )
    );

    v_account_type := btrim(
        coalesce(
            new.raw_user_meta_data ->> 'account_type',
            ''
        )
    );

    v_declaration_accepted :=
        coalesce(
            new.raw_user_meta_data
                ->> 'account_declaration_accepted',
            'false'
        ) = 'true';

    if v_account_type not in
    (
        'adult_learner',
        'guardian_managed_learner'
    ) then
        raise exception 'A valid account declaration is required'
            using errcode = '22023';
    end if;

    if v_declaration_accepted is distinct from true then
        raise exception 'Account declaration must be accepted'
            using errcode = '22023';
    end if;

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

    insert into public.account_declarations
    (
        user_id,
        account_type,
        declaration_version,
        accepted_at
    )
    values
    (
        new.id,
        v_account_type,
        v_declaration_version,
        now()
    );

    return new;
end;
$function$;