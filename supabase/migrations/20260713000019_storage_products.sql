-- 20260713000019_storage_products.sql
-- VOLUME 02 · MDM — bucket de Storage para fotos/mídias de produtos.
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do nothing;

drop policy if exists products_bucket_read   on storage.objects;
drop policy if exists products_bucket_insert on storage.objects;
drop policy if exists products_bucket_update on storage.objects;
drop policy if exists products_bucket_delete on storage.objects;

create policy products_bucket_read   on storage.objects for select to public        using (bucket_id = 'products');
create policy products_bucket_insert on storage.objects for insert to authenticated with check (bucket_id = 'products');
create policy products_bucket_update on storage.objects for update to authenticated using (bucket_id = 'products');
create policy products_bucket_delete on storage.objects for delete to authenticated using (bucket_id = 'products');
