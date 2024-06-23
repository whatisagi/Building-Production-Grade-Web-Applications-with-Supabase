create table "public"."service_users" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "supabase_user" uuid not null,
    "full_name" text
);


alter table "public"."service_users" enable row level security;

create table "public"."tenant_permissions" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "service_user" bigint not null,
    "tenant" text not null
);


alter table "public"."tenant_permissions" enable row level security;

create table "public"."tenants" (
    "id" text not null,
    "created_at" timestamp with time zone not null default now(),
    "name" text not null,
    "domain" text not null
);


alter table "public"."tenants" enable row level security;

CREATE UNIQUE INDEX service_users_pkey ON public.service_users USING btree (id);

CREATE UNIQUE INDEX service_users_supabase_user_key ON public.service_users USING btree (supabase_user);

CREATE UNIQUE INDEX tenant_permissions_pkey ON public.tenant_permissions USING btree (id);

CREATE UNIQUE INDEX tenants_domain_key ON public.tenants USING btree (domain);

CREATE UNIQUE INDEX tenants_pkey ON public.tenants USING btree (id);

alter table "public"."service_users" add constraint "service_users_pkey" PRIMARY KEY using index "service_users_pkey";

alter table "public"."tenant_permissions" add constraint "tenant_permissions_pkey" PRIMARY KEY using index "tenant_permissions_pkey";

alter table "public"."tenants" add constraint "tenants_pkey" PRIMARY KEY using index "tenants_pkey";

alter table "public"."service_users" add constraint "service_users_supabase_user_fkey" FOREIGN KEY (supabase_user) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."service_users" validate constraint "service_users_supabase_user_fkey";

alter table "public"."service_users" add constraint "service_users_supabase_user_key" UNIQUE using index "service_users_supabase_user_key";

alter table "public"."tenant_permissions" add constraint "tenant_permissions_service_user_fkey" FOREIGN KEY (service_user) REFERENCES service_users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."tenant_permissions" validate constraint "tenant_permissions_service_user_fkey";

alter table "public"."tenant_permissions" add constraint "tenant_permissions_tenant_fkey" FOREIGN KEY (tenant) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."tenant_permissions" validate constraint "tenant_permissions_tenant_fkey";

alter table "public"."tenants" add constraint "tenants_domain_key" UNIQUE using index "tenants_domain_key";

grant delete on table "public"."service_users" to "anon";

grant insert on table "public"."service_users" to "anon";

grant references on table "public"."service_users" to "anon";

grant select on table "public"."service_users" to "anon";

grant trigger on table "public"."service_users" to "anon";

grant truncate on table "public"."service_users" to "anon";

grant update on table "public"."service_users" to "anon";

grant delete on table "public"."service_users" to "authenticated";

grant insert on table "public"."service_users" to "authenticated";

grant references on table "public"."service_users" to "authenticated";

grant select on table "public"."service_users" to "authenticated";

grant trigger on table "public"."service_users" to "authenticated";

grant truncate on table "public"."service_users" to "authenticated";

grant update on table "public"."service_users" to "authenticated";

grant delete on table "public"."service_users" to "service_role";

grant insert on table "public"."service_users" to "service_role";

grant references on table "public"."service_users" to "service_role";

grant select on table "public"."service_users" to "service_role";

grant trigger on table "public"."service_users" to "service_role";

grant truncate on table "public"."service_users" to "service_role";

grant update on table "public"."service_users" to "service_role";

grant delete on table "public"."tenant_permissions" to "anon";

grant insert on table "public"."tenant_permissions" to "anon";

grant references on table "public"."tenant_permissions" to "anon";

grant select on table "public"."tenant_permissions" to "anon";

grant trigger on table "public"."tenant_permissions" to "anon";

grant truncate on table "public"."tenant_permissions" to "anon";

grant update on table "public"."tenant_permissions" to "anon";

grant delete on table "public"."tenant_permissions" to "authenticated";

grant insert on table "public"."tenant_permissions" to "authenticated";

grant references on table "public"."tenant_permissions" to "authenticated";

grant select on table "public"."tenant_permissions" to "authenticated";

grant trigger on table "public"."tenant_permissions" to "authenticated";

grant truncate on table "public"."tenant_permissions" to "authenticated";

grant update on table "public"."tenant_permissions" to "authenticated";

grant delete on table "public"."tenant_permissions" to "service_role";

grant insert on table "public"."tenant_permissions" to "service_role";

grant references on table "public"."tenant_permissions" to "service_role";

grant select on table "public"."tenant_permissions" to "service_role";

grant trigger on table "public"."tenant_permissions" to "service_role";

grant truncate on table "public"."tenant_permissions" to "service_role";

grant update on table "public"."tenant_permissions" to "service_role";

grant delete on table "public"."tenants" to "anon";

grant insert on table "public"."tenants" to "anon";

grant references on table "public"."tenants" to "anon";

grant select on table "public"."tenants" to "anon";

grant trigger on table "public"."tenants" to "anon";

grant truncate on table "public"."tenants" to "anon";

grant update on table "public"."tenants" to "anon";

grant delete on table "public"."tenants" to "authenticated";

grant insert on table "public"."tenants" to "authenticated";

grant references on table "public"."tenants" to "authenticated";

grant select on table "public"."tenants" to "authenticated";

grant trigger on table "public"."tenants" to "authenticated";

grant truncate on table "public"."tenants" to "authenticated";

grant update on table "public"."tenants" to "authenticated";

grant delete on table "public"."tenants" to "service_role";

grant insert on table "public"."tenants" to "service_role";

grant references on table "public"."tenants" to "service_role";

grant select on table "public"."tenants" to "service_role";

grant trigger on table "public"."tenants" to "service_role";

grant truncate on table "public"."tenants" to "service_role";

grant update on table "public"."tenants" to "service_role";

create policy "access own user data"
on "public"."service_users"
as permissive
for select
to authenticated
using ((supabase_user = auth.uid()));


create policy "allow reading own permissions"
on "public"."tenant_permissions"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT
   FROM service_users su
  WHERE ((su.id = tenant_permissions.service_user) AND (su.supabase_user = auth.uid())))));


create policy "can read tenant if has permissions"
on "public"."tenants"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT
   FROM tenant_permissions tp
  WHERE (tp.tenant = tenants.id))));



